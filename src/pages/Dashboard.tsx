import { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import {
  Users, Award, Bell, Calendar, AlertCircle, CheckCircle2,
  TrendingUp, DollarSign, ShoppingCart, AlertTriangle, Clock, Package
} from 'lucide-react';

type KPI = {
  contasVencidasValor: number;
  contasVencidasCount: number;
  receberTotalValor: number;
  comprasMesValor: number;
  vendasMesValor: number;
  lucroMes: number;
};

type EstoquePrograma = {
  programa_id: string;
  programa_nome: string;
  total_pontos: number;
  valor_total: number;
};

type Alertas = {
  contasVencidas: number;
  contasHoje: number;
  contas7dias: number;
  receberVencidas: number;
};

type Atividade = {
  id: string;
  tipo_atividade: string;
  titulo: string;
  parceiro_nome: string;
  programa_nome: string;
  quantidade_pontos: number;
  data_prevista: string;
  prioridade: string;
  periodo: string;
  dias_restantes: number;
};

type AtividadeProcessada = {
  id: string;
  tipo_atividade: string;
  titulo: string;
  parceiro_nome: string;
  programa_nome: string;
  quantidade_pontos: number;
  processado_em: string;
};

const fmtBRL = (v: number) =>
  v.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
const fmtPts = (v: number) =>
  v.toLocaleString('pt-BR', { maximumFractionDigits: 0 });
const sum = (arr: Record<string, number>[], key: string) =>
  (arr || []).reduce((s, r) => s + (r[key] || 0), 0);

const TIPO_ICONS: Record<string, string> = {
  transferencia_entrada: '📥',
  transferencia_bonus: '🎁',
  bumerangue_retorno: '🔄',
  clube_credito_mensal: '💳',
  clube_credito_bonus: '⭐',
  outro: '📌',
};

const PRIORIDADE_COLORS: Record<string, string> = {
  baixa: 'bg-slate-100 text-slate-700',
  normal: 'bg-blue-100 text-blue-700',
  alta: 'bg-amber-100 text-amber-700',
  urgente: 'bg-red-100 text-red-700',
};

export default function Dashboard() {
  const [kpi, setKpi] = useState<KPI>({
    contasVencidasValor: 0, contasVencidasCount: 0,
    receberTotalValor: 0, comprasMesValor: 0,
    vendasMesValor: 0, lucroMes: 0,
  });
  const [estoque, setEstoque] = useState<EstoquePrograma[]>([]);
  const [alertas, setAlertas] = useState<Alertas>({ contasVencidas: 0, contasHoje: 0, contas7dias: 0, receberVencidas: 0 });
  const [atividades, setAtividades] = useState<Atividade[]>([]);
  const [atividadesProcessadas, setAtividadesProcessadas] = useState<AtividadeProcessada[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([loadKPI(), loadEstoque(), loadAlertas(), loadAtividades(), loadAtividadesProcessadas()])
      .finally(() => setLoading(false));
  }, []);

  const loadKPI = async () => {
    const hoje = new Date().toISOString().split('T')[0];
    const d = new Date();
    const inicioMes = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-01`;

    const [
      { data: vencidas },
      { data: receber },
      { data: compras },
      { data: comprasBon },
      { data: vendas },
    ] = await Promise.all([
      supabase.from('contas_a_pagar').select('valor_parcela').lt('data_vencimento', hoje).eq('status_pagamento', 'pendente'),
      supabase.from('contas_a_receber').select('valor_parcela').eq('status_pagamento', 'pendente'),
      supabase.from('compras').select('valor_total').gte('data_entrada', inicioMes),
      supabase.from('compra_bonificada').select('custo_total').gte('data_compra', inicioMes),
      supabase.from('vendas').select('valor_total, lucro_real').gte('data_venda', inicioMes).neq('status', 'cancelada'),
    ]);

    setKpi({
      contasVencidasValor: sum(vencidas as any[] || [], 'valor_parcela'),
      contasVencidasCount: (vencidas || []).length,
      receberTotalValor: sum(receber as any[] || [], 'valor_parcela'),
      comprasMesValor: sum(compras as any[] || [], 'valor_total') + sum(comprasBon as any[] || [], 'custo_total'),
      vendasMesValor: sum(vendas as any[] || [], 'valor_total'),
      lucroMes: sum(vendas as any[] || [], 'lucro_real'),
    });
  };

  const loadEstoque = async () => {
    const { data } = await supabase
      .from('estoque_pontos')
      .select('saldo_atual, custo_medio, programa_id, programas_fidelidade(nome)')
      .gt('saldo_atual', 0);

    if (!data) return;

    const map: Record<string, EstoquePrograma> = {};
    for (const row of data) {
      const id = row.programa_id;
      const nome = (row.programas_fidelidade as any)?.nome || 'Desconhecido';
      if (!map[id]) map[id] = { programa_id: id, programa_nome: nome, total_pontos: 0, valor_total: 0 };
      map[id].total_pontos += Number(row.saldo_atual);
      map[id].valor_total += Number(row.saldo_atual) * Number(row.custo_medio || 0) / 1000;
    }

    setEstoque(Object.values(map).sort((a, b) => b.total_pontos - a.total_pontos));
  };

  const loadAlertas = async () => {
    const hoje = new Date().toISOString().split('T')[0];
    const em7dias = new Date(Date.now() + 7 * 86400000).toISOString().split('T')[0];

    const [
      { count: vencidas },
      { count: hojeCount },
      { count: dias7 },
      { count: receberV },
    ] = await Promise.all([
      supabase.from('contas_a_pagar').select('id', { count: 'exact', head: true }).lt('data_vencimento', hoje).eq('status_pagamento', 'pendente'),
      supabase.from('contas_a_pagar').select('id', { count: 'exact', head: true }).eq('data_vencimento', hoje).eq('status_pagamento', 'pendente'),
      supabase.from('contas_a_pagar').select('id', { count: 'exact', head: true }).gt('data_vencimento', hoje).lte('data_vencimento', em7dias).eq('status_pagamento', 'pendente'),
      supabase.from('contas_a_receber').select('id', { count: 'exact', head: true }).lt('data_vencimento', hoje).eq('status_pagamento', 'pendente'),
    ]);

    setAlertas({
      contasVencidas: vencidas || 0,
      contasHoje: hojeCount || 0,
      contas7dias: dias7 || 0,
      receberVencidas: receberV || 0,
    });
  };

  const loadAtividades = async () => {
    const { data } = await supabase
      .from('atividades_pendentes')
      .select('*')
      .in('periodo', ['Hoje', 'Amanhã', 'Esta semana'])
      .limit(10);
    setAtividades(data || []);
  };

  const loadAtividadesProcessadas = async () => {
    const hoje = new Date();
    hoje.setHours(0, 0, 0, 0);
    const amanha = new Date(hoje);
    amanha.setDate(amanha.getDate() + 1);

    const { data } = await supabase
      .from('atividades')
      .select('id, tipo_atividade, titulo, parceiro_nome, programa_nome, quantidade_pontos, processado_em')
      .eq('status', 'concluido')
      .gte('processado_em', hoje.toISOString())
      .lt('processado_em', amanha.toISOString())
      .order('processado_em', { ascending: false })
      .limit(10);

    setAtividadesProcessadas(data || []);
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600" />
      </div>
    );
  }

  const mesLabel = new Date().toLocaleDateString('pt-BR', { month: 'long' });
  const hasAlertas = alertas.contasVencidas > 0 || alertas.contasHoje > 0 || alertas.contas7dias > 0 || alertas.receberVencidas > 0;

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold text-slate-800 mb-1">Dashboard</h1>
        <p className="text-slate-500">Visão geral do sistema MSA Milhas e Turismo</p>
      </div>

      {/* KPIs Financeiros */}
      <section>
        <h2 className="text-xs font-semibold text-slate-400 uppercase tracking-widest mb-3">Financeiro</h2>
        <div className="grid grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-4">
          <KpiCard
            title="A Pagar Vencido"
            value={fmtBRL(kpi.contasVencidasValor)}
            sub={`${kpi.contasVencidasCount} parcela${kpi.contasVencidasCount !== 1 ? 's' : ''}`}
            icon={AlertTriangle}
            iconBg="bg-red-50"
            iconColor="text-red-500"
            valueColor={kpi.contasVencidasCount > 0 ? 'text-red-600' : 'text-slate-800'}
            borderColor={kpi.contasVencidasCount > 0 ? 'border-red-200' : 'border-slate-200'}
          />
          <KpiCard
            title="A Receber"
            value={fmtBRL(kpi.receberTotalValor)}
            sub="em aberto"
            icon={TrendingUp}
            iconBg="bg-green-50"
            iconColor="text-green-600"
          />
          <KpiCard
            title={`Compras — ${mesLabel}`}
            value={fmtBRL(kpi.comprasMesValor)}
            sub="total do mês"
            icon={ShoppingCart}
            iconBg="bg-blue-50"
            iconColor="text-blue-600"
          />
          <KpiCard
            title={`Vendas — ${mesLabel}`}
            value={fmtBRL(kpi.vendasMesValor)}
            sub="total do mês"
            icon={Award}
            iconBg="bg-indigo-50"
            iconColor="text-indigo-600"
          />
          <KpiCard
            title="Lucro do Mês"
            value={fmtBRL(kpi.lucroMes)}
            sub="em vendas concluídas"
            icon={DollarSign}
            iconBg={kpi.lucroMes >= 0 ? 'bg-emerald-50' : 'bg-red-50'}
            iconColor={kpi.lucroMes >= 0 ? 'text-emerald-600' : 'text-red-600'}
            valueColor={kpi.lucroMes >= 0 ? 'text-emerald-700' : 'text-red-600'}
          />
        </div>
      </section>

      {/* Estoque por Programa */}
      {estoque.length > 0 && (
        <section>
          <h2 className="text-xs font-semibold text-slate-400 uppercase tracking-widest mb-3">Estoque de Pontos</h2>
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-4">
            {estoque.map((prog) => (
              <div key={prog.programa_id} className="bg-white rounded-xl border border-slate-200 p-4 shadow-sm">
                <div className="flex items-center gap-2 mb-3">
                  <div className="bg-purple-50 p-1.5 rounded-lg flex-shrink-0">
                    <Package className="w-4 h-4 text-purple-600" />
                  </div>
                  <span className="font-semibold text-slate-700 text-sm truncate">{prog.programa_nome}</span>
                </div>
                <p className="text-2xl font-bold text-slate-800">{fmtPts(prog.total_pontos)}</p>
                <p className="text-xs text-slate-400 mt-1">pts · {fmtBRL(prog.valor_total)}</p>
              </div>
            ))}
          </div>
        </section>
      )}

      {/* Alertas */}
      {hasAlertas && (
        <section>
          <h2 className="text-xs font-semibold text-slate-400 uppercase tracking-widest mb-3">Alertas</h2>
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
            {alertas.contasVencidas > 0 && (
              <AlertaCard icon={AlertTriangle} label="Contas vencidas" count={alertas.contasVencidas} desc="a pagar em atraso" scheme="red" />
            )}
            {alertas.contasHoje > 0 && (
              <AlertaCard icon={Clock} label="Vencem hoje" count={alertas.contasHoje} desc="contas a pagar" scheme="orange" />
            )}
            {alertas.contas7dias > 0 && (
              <AlertaCard icon={Calendar} label="Vencem em 7 dias" count={alertas.contas7dias} desc="contas a pagar" scheme="amber" />
            )}
            {alertas.receberVencidas > 0 && (
              <AlertaCard icon={AlertCircle} label="A receber vencido" count={alertas.receberVencidas} desc="parcelas em atraso" scheme="rose" />
            )}
          </div>
        </section>
      )}

      {/* Atividades */}
      <section className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Pendentes */}
        <div className="bg-white rounded-xl border border-slate-200 shadow-sm p-6">
          <div className="flex items-center gap-3 mb-5">
            <div className="bg-amber-50 p-2 rounded-lg">
              <Bell className="w-5 h-5 text-amber-500" />
            </div>
            <div>
              <h3 className="font-bold text-slate-800">Atividades Pendentes</h3>
              <p className="text-xs text-slate-500">Entradas de pontos desta semana</p>
            </div>
          </div>

          {atividades.length === 0 ? (
            <div className="text-center py-10 text-slate-400">
              <AlertCircle className="w-10 h-10 mx-auto mb-2 opacity-40" />
              <p className="text-sm">Nenhuma atividade pendente</p>
            </div>
          ) : (
            <div className="space-y-2">
              {atividades.map((a) => (
                <div key={a.id} className="border border-slate-100 rounded-lg p-3 hover:bg-slate-50 transition-colors">
                  <div className="flex items-start justify-between gap-3">
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-1.5 mb-1 flex-wrap">
                        <span className="text-base">{TIPO_ICONS[a.tipo_atividade] || '📌'}</span>
                        <span className="font-medium text-slate-800 text-sm truncate">{a.titulo}</span>
                        <span className={`px-1.5 py-0.5 rounded-full text-xs font-medium flex-shrink-0 ${PRIORIDADE_COLORS[a.prioridade] || 'bg-slate-100 text-slate-600'}`}>
                          {a.prioridade}
                        </span>
                      </div>
                      <div className="flex flex-wrap gap-2 text-xs text-slate-500">
                        {a.parceiro_nome && (
                          <span className="flex items-center gap-1">
                            <Users className="w-3 h-3" />{a.parceiro_nome}
                          </span>
                        )}
                        {a.quantidade_pontos > 0 && (
                          <span className="text-green-600 font-semibold">+{fmtPts(a.quantidade_pontos)} pts</span>
                        )}
                      </div>
                    </div>
                    <div className="text-right flex-shrink-0">
                      <div className="flex items-center gap-1 text-xs text-slate-500 mb-0.5">
                        <Calendar className="w-3 h-3" />
                        {a.data_prevista
                          ? new Date(a.data_prevista + 'T00:00:00').toLocaleDateString('pt-BR')
                          : '-'}
                      </div>
                      <span className="text-xs text-slate-400">{a.periodo}{a.dias_restantes > 0 ? ` (${a.dias_restantes}d)` : ''}</span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Creditados hoje */}
        <div className="bg-gradient-to-br from-green-50 to-emerald-50 rounded-xl border border-green-200 shadow-sm p-6">
          <div className="flex items-center gap-3 mb-5">
            <div className="bg-green-100 p-2 rounded-lg">
              <CheckCircle2 className="w-5 h-5 text-green-600" />
            </div>
            <div>
              <h3 className="font-bold text-slate-800">Pontos Creditados Hoje</h3>
              <p className="text-xs text-slate-500">Entradas processadas hoje</p>
            </div>
          </div>

          {atividadesProcessadas.length === 0 ? (
            <div className="text-center py-10 text-slate-400">
              <CheckCircle2 className="w-10 h-10 mx-auto mb-2 opacity-30" />
              <p className="text-sm">Nenhum ponto creditado hoje</p>
            </div>
          ) : (
            <div className="space-y-2">
              {atividadesProcessadas.map((a) => (
                <div key={a.id} className="bg-white border border-green-200 rounded-lg p-3 hover:shadow-sm transition-shadow">
                  <div className="flex items-start justify-between gap-3">
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-1.5 mb-1 flex-wrap">
                        <span className="text-base">{TIPO_ICONS[a.tipo_atividade] || '📌'}</span>
                        <span className="font-medium text-slate-800 text-sm truncate">{a.titulo}</span>
                        <span className="px-1.5 py-0.5 rounded-full text-xs bg-green-100 text-green-700 flex-shrink-0">Creditado</span>
                      </div>
                      <div className="flex flex-wrap gap-2 text-xs text-slate-500">
                        {a.parceiro_nome && (
                          <span className="flex items-center gap-1">
                            <Users className="w-3 h-3" />{a.parceiro_nome}
                          </span>
                        )}
                        {a.quantidade_pontos > 0 && (
                          <span className="text-green-600 font-semibold">+{fmtPts(a.quantidade_pontos)} pts</span>
                        )}
                      </div>
                    </div>
                    <span className="text-xs text-slate-400 flex-shrink-0">
                      {new Date(a.processado_em).toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </section>
    </div>
  );
}

function KpiCard({
  title, value, sub, icon: Icon,
  iconBg, iconColor,
  valueColor = 'text-slate-800',
  borderColor = 'border-slate-200',
}: {
  title: string;
  value: string;
  sub: string;
  icon: React.ComponentType<{ className?: string }>;
  iconBg: string;
  iconColor: string;
  valueColor?: string;
  borderColor?: string;
}) {
  return (
    <div className={`bg-white rounded-xl border shadow-sm p-4 ${borderColor}`}>
      <div className={`inline-flex p-2 rounded-lg mb-3 ${iconBg}`}>
        <Icon className={`w-4 h-4 ${iconColor}`} />
      </div>
      <p className="text-xs text-slate-500 font-medium mb-1 leading-tight">{title}</p>
      <p className={`text-lg font-bold ${valueColor}`}>{value}</p>
      <p className="text-xs text-slate-400 mt-0.5">{sub}</p>
    </div>
  );
}

const ALERTA_SCHEMES = {
  red:    'bg-red-50 border-red-200 text-red-700',
  orange: 'bg-orange-50 border-orange-200 text-orange-700',
  amber:  'bg-amber-50 border-amber-200 text-amber-700',
  rose:   'bg-rose-50 border-rose-200 text-rose-700',
} as const;

function AlertaCard({
  icon: Icon, label, count, desc, scheme,
}: {
  icon: React.ComponentType<{ className?: string }>;
  label: string;
  count: number;
  desc: string;
  scheme: keyof typeof ALERTA_SCHEMES;
}) {
  return (
    <div className={`rounded-xl border p-4 ${ALERTA_SCHEMES[scheme]}`}>
      <div className="flex items-center gap-2 mb-1">
        <Icon className="w-4 h-4" />
        <span className="font-semibold text-sm">{label}</span>
      </div>
      <p className="text-2xl font-bold">{count}</p>
      <p className="text-xs opacity-70 mt-0.5">{desc}</p>
    </div>
  );
}
