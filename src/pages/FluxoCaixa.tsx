import { useEffect, useState, useCallback } from 'react';
import { supabase } from '../lib/supabase';
import { formatCurrency, formatDate } from '../lib/formatters';
import { Bar } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale, LinearScale, BarElement,
  Title, Tooltip, Legend
} from 'chart.js';
import {
  TrendingUp, TrendingDown, Wallet, Building2,
  ArrowDownCircle, ArrowUpCircle, CheckCircle2,
  Clock, AlertCircle, RefreshCw
} from 'lucide-react';

ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend);

type KPIs = {
  saldoBancario: number;
  totalEntradas: number;
  totalSaidas: number;
  saldoFinal: number;
  qtdEntradas: number;
  qtdSaidas: number;
  aReceberPendente: number;
  aPagarPendente: number;
};

type FluxoDia = {
  label: string;
  entradas: number;
  saidas: number;
};

type ProjecaoSemana = {
  label: string;
  aReceber: number;
  aPagar: number;
};

type Transacao = {
  data: string;
  descricao: string;
  categoria: string;
  tipo: 'entrada' | 'saida';
  valor: number;
  status: string;
};

function getMeses() {
  const lista = [];
  const now = new Date();
  for (let i = 0; i < 12; i++) {
    const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
    const val = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
    const label = d.toLocaleDateString('pt-BR', { month: 'long', year: 'numeric' });
    lista.push({ val, label: label.charAt(0).toUpperCase() + label.slice(1) });
  }
  return lista;
}

function getDiasDoMes(mes: string) {
  const [ano, m] = mes.split('-').map(Number);
  const total = new Date(ano, m, 0).getDate();
  return Array.from({ length: total }, (_, i) => {
    const d = String(i + 1).padStart(2, '0');
    return { key: `${mes}-${d}`, label: `${d}/${String(m).padStart(2, '0')}` };
  });
}

function getProximasOitoSemanas() {
  const semanas = [];
  const hoje = new Date();
  for (let i = 0; i < 8; i++) {
    const inicio = new Date(hoje);
    inicio.setDate(hoje.getDate() + i * 7);
    const fim = new Date(inicio);
    fim.setDate(inicio.getDate() + 6);
    semanas.push({
      label: `${inicio.getDate().toString().padStart(2, '0')}/${(inicio.getMonth() + 1).toString().padStart(2, '0')}`,
      inicio: inicio.toISOString().split('T')[0],
      fim: fim.toISOString().split('T')[0]
    });
  }
  return semanas;
}

const CHART_OPTS = (isMobile = false) => ({
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: { position: 'top' as const, labels: { font: { size: 10 }, padding: 8 } },
    tooltip: {
      callbacks: {
        label: (ctx: any) => ` ${formatCurrency(ctx.raw as number)}`
      }
    }
  },
  scales: {
    x: {
      grid: { display: false },
      ticks: { font: { size: isMobile ? 8 : 9 }, maxRotation: 45 }
    },
    y: {
      grid: { color: 'rgba(0,0,0,0.05)' },
      ticks: {
        font: { size: 9 },
        callback: (v: any) => v >= 1000 ? `R$${(v / 1000).toFixed(0)}k` : `R$${v}`
      }
    }
  }
});

function KpiCard({
  title, value, sub, icon: Icon, color, loading
}: {
  title: string; value: string; sub: string;
  icon: React.ComponentType<{ className?: string }>;
  color: 'green' | 'red' | 'blue' | 'purple';
  loading: boolean;
}) {
  const colors = {
    green:  { border: 'border-t-green-500',  bg: 'bg-green-50',   icon: 'text-green-600',  val: 'text-green-700' },
    red:    { border: 'border-t-red-500',    bg: 'bg-red-50',     icon: 'text-red-600',    val: 'text-red-700' },
    blue:   { border: 'border-t-blue-500',   bg: 'bg-blue-50',    icon: 'text-blue-600',   val: 'text-blue-700' },
    purple: { border: 'border-t-purple-500', bg: 'bg-purple-50',  icon: 'text-purple-600', val: 'text-purple-700' },
  };
  const c = colors[color];
  return (
    <div className={`bg-white rounded-xl border border-t-4 shadow-sm p-4 ${c.border}`}>
      <div className={`inline-flex p-2 rounded-lg mb-3 ${c.bg}`}>
        <Icon className={`w-4 h-4 ${c.icon}`} />
      </div>
      <p className="text-xs text-slate-500 font-medium mb-1 uppercase tracking-wide">{title}</p>
      {loading ? (
        <div className="h-7 w-24 bg-slate-100 rounded animate-pulse mb-1" />
      ) : (
        <p className={`text-xl font-bold ${c.val}`}>{value}</p>
      )}
      <p className="text-xs text-slate-400 mt-0.5">{sub}</p>
    </div>
  );
}

function StatusBadge({ status }: { status: string }) {
  const map: Record<string, string> = {
    pago:     'bg-green-100 text-green-700',
    recebido: 'bg-green-100 text-green-700',
    pendente: 'bg-amber-100 text-amber-700',
    atrasado: 'bg-red-100 text-red-700',
    parcial:  'bg-blue-100 text-blue-700',
  };
  const labels: Record<string, string> = {
    pago: 'Pago', recebido: 'Recebido', pendente: 'Pendente',
    atrasado: 'Atrasado', parcial: 'Parcial'
  };
  return (
    <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${map[status] || 'bg-slate-100 text-slate-600'}`}>
      {labels[status] || status}
    </span>
  );
}

export default function FluxoCaixa() {
  const meses = getMeses();
  const [mesSel, setMesSel] = useState(meses[0].val);
  const [loading, setLoading] = useState(true);
  const [kpis, setKpis] = useState<KPIs>({
    saldoBancario: 0, totalEntradas: 0, totalSaidas: 0, saldoFinal: 0,
    qtdEntradas: 0, qtdSaidas: 0, aReceberPendente: 0, aPagarPendente: 0
  });
  const [fluxoDiario, setFluxoDiario] = useState<FluxoDia[]>([]);
  const [projecao, setProjecao] = useState<ProjecaoSemana[]>([]);
  const [transacoes, setTransacoes] = useState<Transacao[]>([]);

  const loadKpis = useCallback(async (mes: string) => {
    const [bancosRes, receberRes, pagarRes, receberPendRes, pagarPendRes] = await Promise.all([
      supabase.from('contas_bancarias').select('saldo_inicial').eq('ativo', true),
      supabase.from('contas_receber')
        .select('valor_pago, valor_parcela')
        .eq('status_pagamento', 'pago')
        .gte('data_pagamento', `${mes}-01`)
        .lte('data_pagamento', `${mes}-31`),
      supabase.from('contas_a_pagar')
        .select('valor_pago, valor_parcela')
        .eq('status_pagamento', 'pago')
        .gte('data_pagamento', `${mes}-01`)
        .lte('data_pagamento', `${mes}-31`),
      supabase.from('contas_receber')
        .select('valor_parcela')
        .in('status_pagamento', ['pendente', 'atrasado']),
      supabase.from('contas_a_pagar')
        .select('valor_parcela')
        .in('status_pagamento', ['pendente', 'atrasado']),
    ]);

    const saldoBancario = (bancosRes.data || []).reduce((s, b) => s + (b.saldo_inicial || 0), 0);
    const totalEntradas = (receberRes.data || []).reduce((s, r) => s + (r.valor_pago ?? r.valor_parcela ?? 0), 0);
    const totalSaidas = (pagarRes.data || []).reduce((s, p) => s + (p.valor_pago ?? p.valor_parcela ?? 0), 0);
    const aReceberPendente = (receberPendRes.data || []).reduce((s, r) => s + (r.valor_parcela || 0), 0);
    const aPagarPendente = (pagarPendRes.data || []).reduce((s, p) => s + (p.valor_parcela || 0), 0);

    setKpis({
      saldoBancario,
      totalEntradas,
      totalSaidas,
      saldoFinal: saldoBancario + totalEntradas - totalSaidas,
      qtdEntradas: receberRes.data?.length || 0,
      qtdSaidas: pagarRes.data?.length || 0,
      aReceberPendente,
      aPagarPendente
    });
  }, []);

  const loadFluxoDiario = useCallback(async (mes: string) => {
    const dias = getDiasDoMes(mes);
    const inicio = `${mes}-01`;
    const fim = `${mes}-${String(new Date(parseInt(mes.split('-')[0]), parseInt(mes.split('-')[1]), 0).getDate()).padStart(2, '0')}`;

    const [receberRes, pagarRes] = await Promise.all([
      supabase.from('contas_receber')
        .select('data_vencimento, valor_parcela, data_pagamento, valor_pago, status_pagamento')
        .gte('data_vencimento', inicio)
        .lte('data_vencimento', fim)
        .not('status_pagamento', 'eq', 'cancelado'),
      supabase.from('contas_a_pagar')
        .select('data_vencimento, valor_parcela, data_pagamento, valor_pago, status_pagamento')
        .gte('data_vencimento', inicio)
        .lte('data_vencimento', fim)
        .not('status_pagamento', 'eq', 'cancelado'),
    ]);

    const entradasPorDia: Record<string, number> = {};
    const saidasPorDia: Record<string, number> = {};

    for (const d of dias) {
      entradasPorDia[d.key] = 0;
      saidasPorDia[d.key] = 0;
    }

    for (const r of receberRes.data || []) {
      const key = r.data_vencimento;
      if (entradasPorDia[key] !== undefined)
        entradasPorDia[key] += r.valor_pago ?? r.valor_parcela ?? 0;
    }
    for (const p of pagarRes.data || []) {
      const key = p.data_vencimento;
      if (saidasPorDia[key] !== undefined)
        saidasPorDia[key] += p.valor_pago ?? p.valor_parcela ?? 0;
    }

    // Agrupa a cada 3 dias para não sobrecarregar o gráfico
    const agrupado: FluxoDia[] = [];
    for (let i = 0; i < dias.length; i += 3) {
      const grupo = dias.slice(i, i + 3);
      agrupado.push({
        label: grupo[0].label,
        entradas: grupo.reduce((s, d) => s + entradasPorDia[d.key], 0),
        saidas: grupo.reduce((s, d) => s + saidasPorDia[d.key], 0),
      });
    }
    setFluxoDiario(agrupado);
  }, []);

  const loadProjecao = useCallback(async () => {
    const semanas = getProximasOitoSemanas();
    const resultado: ProjecaoSemana[] = [];

    for (const sem of semanas) {
      const [recRes, pagRes] = await Promise.all([
        supabase.from('contas_receber')
          .select('valor_parcela')
          .in('status_pagamento', ['pendente', 'atrasado'])
          .gte('data_vencimento', sem.inicio)
          .lte('data_vencimento', sem.fim),
        supabase.from('contas_a_pagar')
          .select('valor_parcela')
          .in('status_pagamento', ['pendente', 'atrasado'])
          .gte('data_vencimento', sem.inicio)
          .lte('data_vencimento', sem.fim),
      ]);
      resultado.push({
        label: sem.label,
        aReceber: (recRes.data || []).reduce((s, r) => s + (r.valor_parcela || 0), 0),
        aPagar: (pagRes.data || []).reduce((s, p) => s + (p.valor_parcela || 0), 0),
      });
    }
    setProjecao(resultado);
  }, []);

  const loadTransacoes = useCallback(async (mes: string) => {
    const inicio = `${mes}-01`;
    const fim = `${mes}-${String(new Date(parseInt(mes.split('-')[0]), parseInt(mes.split('-')[1]), 0).getDate()).padStart(2, '0')}`;

    const [receberRes, pagarRes] = await Promise.all([
      supabase.from('contas_receber')
        .select('data_vencimento, data_pagamento, valor_parcela, valor_pago, status_pagamento, observacao, origem_tipo')
        .gte('data_vencimento', inicio)
        .lte('data_vencimento', fim)
        .not('status_pagamento', 'eq', 'cancelado')
        .order('data_vencimento', { ascending: true }),
      supabase.from('contas_a_pagar')
        .select('data_vencimento, data_pagamento, valor_parcela, valor_pago, status_pagamento, descricao, parceiro:parceiros(nome_parceiro)')
        .gte('data_vencimento', inicio)
        .lte('data_vencimento', fim)
        .not('status_pagamento', 'eq', 'cancelado')
        .order('data_vencimento', { ascending: true }),
    ]);

    const lista: Transacao[] = [];

    for (const r of receberRes.data || []) {
      lista.push({
        data: r.data_vencimento,
        descricao: r.observacao || (r.origem_tipo === 'venda' ? 'Venda de Milhas' : 'Recebimento'),
        categoria: r.origem_tipo === 'venda' ? 'Receita Venda' : 'A/R',
        tipo: 'entrada',
        valor: r.valor_pago ?? r.valor_parcela ?? 0,
        status: r.status_pagamento,
      });
    }

    for (const p of pagarRes.data || []) {
      const parceiro = (p.parceiro as any)?.nome_parceiro;
      lista.push({
        data: p.data_vencimento,
        descricao: p.descricao || (parceiro ? `Pgto ${parceiro}` : 'Pagamento'),
        categoria: 'Contas a Pagar',
        tipo: 'saida',
        valor: p.valor_pago ?? p.valor_parcela ?? 0,
        status: p.status_pagamento,
      });
    }

    lista.sort((a, b) => a.data.localeCompare(b.data));
    setTransacoes(lista);
  }, []);

  const loadAll = useCallback(async (mes: string) => {
    setLoading(true);
    try {
      await Promise.all([
        loadKpis(mes),
        loadFluxoDiario(mes),
        loadTransacoes(mes),
        loadProjecao(),
      ]);
    } finally {
      setLoading(false);
    }
  }, [loadKpis, loadFluxoDiario, loadTransacoes, loadProjecao]);

  useEffect(() => { loadAll(mesSel); }, [mesSel, loadAll]);

  const fluxoDiarioData = {
    labels: fluxoDiario.map(d => d.label),
    datasets: [
      {
        label: 'Entradas',
        data: fluxoDiario.map(d => d.entradas),
        backgroundColor: 'rgba(16,185,129,0.7)',
        borderRadius: 4,
      },
      {
        label: 'Saídas',
        data: fluxoDiario.map(d => d.saidas),
        backgroundColor: 'rgba(239,68,68,0.7)',
        borderRadius: 4,
      }
    ]
  };

  const projecaoData = {
    labels: projecao.map(s => s.label),
    datasets: [
      {
        label: 'A Receber',
        data: projecao.map(s => s.aReceber),
        backgroundColor: 'rgba(59,130,246,0.7)',
        borderRadius: 4,
      },
      {
        label: 'A Pagar',
        data: projecao.map(s => s.aPagar),
        backgroundColor: 'rgba(245,158,11,0.7)',
        borderRadius: 4,
      }
    ]
  };

  const mesSelecionadoLabel = meses.find(m => m.val === mesSel)?.label || '';
  const saldoLiquido = kpis.totalEntradas - kpis.totalSaidas;

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-3">
        <div>
          <h1 className="text-2xl font-bold text-slate-800">Fluxo de Caixa</h1>
          <p className="text-sm text-slate-500 mt-0.5">Entradas, saídas e projeção financeira</p>
        </div>
        <div className="flex items-center gap-3">
          <select
            value={mesSel}
            onChange={e => setMesSel(e.target.value)}
            className="px-3 py-2 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 bg-white"
          >
            {meses.map(m => (
              <option key={m.val} value={m.val}>{m.label}</option>
            ))}
          </select>
          <button
            onClick={() => loadAll(mesSel)}
            className="p-2 text-slate-500 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
            title="Atualizar"
          >
            <RefreshCw className="w-4 h-4" />
          </button>
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <KpiCard
          title="Saldo em Contas"
          value={formatCurrency(kpis.saldoBancario)}
          sub="Soma das contas bancárias"
          icon={Building2}
          color="blue"
          loading={loading}
        />
        <KpiCard
          title="Entradas no Mês"
          value={formatCurrency(kpis.totalEntradas)}
          sub={`${kpis.qtdEntradas} pagamentos recebidos`}
          icon={ArrowDownCircle}
          color="green"
          loading={loading}
        />
        <KpiCard
          title="Saídas no Mês"
          value={formatCurrency(kpis.totalSaidas)}
          sub={`${kpis.qtdSaidas} pagamentos efetuados`}
          icon={ArrowUpCircle}
          color="red"
          loading={loading}
        />
        <KpiCard
          title="Resultado do Mês"
          value={formatCurrency(Math.abs(saldoLiquido))}
          sub={saldoLiquido >= 0 ? 'Superávit no período' : 'Déficit no período'}
          icon={saldoLiquido >= 0 ? TrendingUp : TrendingDown}
          color={saldoLiquido >= 0 ? 'green' : 'red'}
          loading={loading}
        />
      </div>

      {/* Alertas de pendências */}
      {!loading && (kpis.aReceberPendente > 0 || kpis.aPagarPendente > 0) && (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
          {kpis.aReceberPendente > 0 && (
            <div className="flex items-start gap-3 p-3 bg-blue-50 border border-blue-200 rounded-lg">
              <Clock className="w-4 h-4 text-blue-600 mt-0.5 shrink-0" />
              <div>
                <p className="text-sm font-semibold text-blue-800">A Receber (em aberto)</p>
                <p className="text-xs text-blue-600">{formatCurrency(kpis.aReceberPendente)} em parcelas pendentes/atrasadas</p>
              </div>
            </div>
          )}
          {kpis.aPagarPendente > 0 && (
            <div className="flex items-start gap-3 p-3 bg-amber-50 border border-amber-200 rounded-lg">
              <AlertCircle className="w-4 h-4 text-amber-600 mt-0.5 shrink-0" />
              <div>
                <p className="text-sm font-semibold text-amber-800">A Pagar (em aberto)</p>
                <p className="text-xs text-amber-600">{formatCurrency(kpis.aPagarPendente)} em contas pendentes/atrasadas</p>
              </div>
            </div>
          )}
        </div>
      )}

      {/* Workflow */}
      <div className="bg-white rounded-xl border border-slate-200 shadow-sm p-5">
        <h3 className="text-sm font-semibold text-slate-700 mb-4">Ciclo Financeiro</h3>
        <div className="flex items-start overflow-x-auto pb-2 gap-0">
          {[
            { ico: '💰', label: 'Venda Realizada', state: 'done' },
            { ico: '📥', label: 'A/R Gerado', state: 'done' },
            { ico: '🔔', label: 'Cobrança / Venc.', state: 'active' },
            { ico: '💳', label: 'Pgto Recebido', state: 'pending' },
            { ico: '🏦', label: 'Baixa no Banco', state: 'pending' },
            { ico: '🔄', label: 'Conciliação', state: 'pending' },
            { ico: '✅', label: 'Lançamento', state: 'pending' },
          ].map((step, i, arr) => (
            <div key={i} className="flex items-center flex-1 min-w-0">
              <div className="flex flex-col items-center flex-1">
                <div className={`w-10 h-10 rounded-full flex items-center justify-center text-lg mb-1.5 border-2
                  ${step.state === 'done'    ? 'border-green-400 bg-green-50' :
                    step.state === 'active'  ? 'border-blue-500 bg-blue-50 shadow-md shadow-blue-100' :
                                               'border-slate-200 bg-slate-50 opacity-50'}`}>
                  {step.ico}
                </div>
                <span className={`text-xs font-medium text-center leading-tight
                  ${step.state === 'done'   ? 'text-green-600' :
                    step.state === 'active' ? 'text-blue-600' :
                                              'text-slate-400'}`}>
                  {step.label}
                </span>
              </div>
              {i < arr.length - 1 && (
                <div className="text-slate-300 text-sm font-bold mx-1 mb-4">›</div>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <div className="bg-white rounded-xl border border-slate-200 shadow-sm p-5">
          <div className="mb-3">
            <h3 className="text-sm font-semibold text-slate-700">Fluxo por Vencimento — {mesSelecionadoLabel}</h3>
            <p className="text-xs text-slate-400 mt-0.5">Entradas e saídas agrupadas a cada 3 dias</p>
          </div>
          <div className="h-52">
            {loading ? (
              <div className="h-full bg-slate-50 rounded-lg animate-pulse" />
            ) : fluxoDiario.every(d => d.entradas === 0 && d.saidas === 0) ? (
              <div className="h-full flex items-center justify-center text-slate-400 text-sm">Sem movimentações no período</div>
            ) : (
              <Bar data={fluxoDiarioData} options={CHART_OPTS()} />
            )}
          </div>
        </div>

        <div className="bg-white rounded-xl border border-slate-200 shadow-sm p-5">
          <div className="mb-3">
            <h3 className="text-sm font-semibold text-slate-700">Projeção — Próximas 8 Semanas</h3>
            <p className="text-xs text-slate-400 mt-0.5">Vencimentos pendentes agrupados por semana</p>
          </div>
          <div className="h-52">
            {loading ? (
              <div className="h-full bg-slate-50 rounded-lg animate-pulse" />
            ) : projecao.every(s => s.aReceber === 0 && s.aPagar === 0) ? (
              <div className="h-full flex items-center justify-center text-slate-400 text-sm">Sem vencimentos projetados</div>
            ) : (
              <Bar data={projecaoData} options={CHART_OPTS()} />
            )}
          </div>
        </div>
      </div>

      {/* Resumo do mês */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        {[
          { label: 'Entradas Realizadas', value: formatCurrency(kpis.totalEntradas), icon: CheckCircle2, color: 'text-green-600 bg-green-50' },
          { label: 'Saídas Realizadas',   value: formatCurrency(kpis.totalSaidas),   icon: CheckCircle2, color: 'text-red-600 bg-red-50' },
          { label: 'A Receber (aberto)',  value: formatCurrency(kpis.aReceberPendente), icon: Clock, color: 'text-blue-600 bg-blue-50' },
          { label: 'A Pagar (aberto)',    value: formatCurrency(kpis.aPagarPendente),   icon: AlertCircle, color: 'text-amber-600 bg-amber-50' },
        ].map((item, i) => (
          <div key={i} className="bg-white rounded-xl border border-slate-200 shadow-sm p-4 flex items-center gap-3">
            <div className={`p-2 rounded-lg ${item.color.split(' ')[1]}`}>
              <item.icon className={`w-4 h-4 ${item.color.split(' ')[0]}`} />
            </div>
            <div className="min-w-0">
              <p className="text-xs text-slate-500 truncate">{item.label}</p>
              {loading ? (
                <div className="h-5 w-20 bg-slate-100 rounded animate-pulse mt-0.5" />
              ) : (
                <p className="text-sm font-bold text-slate-800">{item.value}</p>
              )}
            </div>
          </div>
        ))}
      </div>

      {/* Tabela detalhamento */}
      <div className="bg-white rounded-xl border border-slate-200 shadow-sm">
        <div className="flex items-center justify-between p-5 border-b border-slate-100">
          <div>
            <h3 className="text-sm font-semibold text-slate-700">Detalhamento do Fluxo</h3>
            <p className="text-xs text-slate-400 mt-0.5">{mesSelecionadoLabel} · {transacoes.length} transações</p>
          </div>
          <div className="flex items-center gap-2 text-xs text-slate-500">
            <span className="flex items-center gap-1"><span className="w-2 h-2 rounded-full bg-green-500 inline-block"></span> Entrada</span>
            <span className="flex items-center gap-1"><span className="w-2 h-2 rounded-full bg-red-500 inline-block"></span> Saída</span>
          </div>
        </div>

        {loading ? (
          <div className="p-6 space-y-3">
            {Array.from({ length: 5 }).map((_, i) => (
              <div key={i} className="h-10 bg-slate-50 rounded animate-pulse" />
            ))}
          </div>
        ) : transacoes.length === 0 ? (
          <div className="p-12 text-center">
            <Wallet className="w-10 h-10 text-slate-300 mx-auto mb-2" />
            <p className="text-slate-400 text-sm">Nenhuma transação no período selecionado</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-slate-100">
                  <th className="text-left px-5 py-3 text-xs font-medium text-slate-500 uppercase tracking-wide">Data</th>
                  <th className="text-left px-5 py-3 text-xs font-medium text-slate-500 uppercase tracking-wide">Descrição</th>
                  <th className="text-left px-5 py-3 text-xs font-medium text-slate-500 uppercase tracking-wide">Categoria</th>
                  <th className="text-right px-5 py-3 text-xs font-medium text-slate-500 uppercase tracking-wide">Entrada</th>
                  <th className="text-right px-5 py-3 text-xs font-medium text-slate-500 uppercase tracking-wide">Saída</th>
                  <th className="text-center px-5 py-3 text-xs font-medium text-slate-500 uppercase tracking-wide">Status</th>
                </tr>
              </thead>
              <tbody>
                {transacoes.map((t, i) => (
                  <tr key={i} className="border-b border-slate-50 hover:bg-slate-50 transition-colors">
                    <td className="px-5 py-3 text-slate-600 whitespace-nowrap">{formatDate(t.data)}</td>
                    <td className="px-5 py-3">
                      <div className="flex items-center gap-2">
                        <div className={`w-1.5 h-1.5 rounded-full shrink-0 ${t.tipo === 'entrada' ? 'bg-green-500' : 'bg-red-500'}`} />
                        <span className="text-slate-700 truncate max-w-xs">{t.descricao}</span>
                      </div>
                    </td>
                    <td className="px-5 py-3">
                      <span className={`px-2 py-0.5 rounded-full text-xs font-medium
                        ${t.tipo === 'entrada' ? 'bg-green-50 text-green-700' : 'bg-slate-100 text-slate-600'}`}>
                        {t.categoria}
                      </span>
                    </td>
                    <td className="px-5 py-3 text-right font-medium">
                      {t.tipo === 'entrada' ? (
                        <span className="text-green-600">{formatCurrency(t.valor)}</span>
                      ) : <span className="text-slate-300">—</span>}
                    </td>
                    <td className="px-5 py-3 text-right font-medium">
                      {t.tipo === 'saida' ? (
                        <span className="text-red-600">{formatCurrency(t.valor)}</span>
                      ) : <span className="text-slate-300">—</span>}
                    </td>
                    <td className="px-5 py-3 text-center">
                      <StatusBadge status={t.status} />
                    </td>
                  </tr>
                ))}
              </tbody>
              <tfoot>
                <tr className="bg-slate-50">
                  <td colSpan={3} className="px-5 py-3 text-xs font-semibold text-slate-600 uppercase tracking-wide">Total do Período</td>
                  <td className="px-5 py-3 text-right font-bold text-green-600">
                    {formatCurrency(transacoes.filter(t => t.tipo === 'entrada').reduce((s, t) => s + t.valor, 0))}
                  </td>
                  <td className="px-5 py-3 text-right font-bold text-red-600">
                    {formatCurrency(transacoes.filter(t => t.tipo === 'saida').reduce((s, t) => s + t.valor, 0))}
                  </td>
                  <td />
                </tr>
              </tfoot>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
