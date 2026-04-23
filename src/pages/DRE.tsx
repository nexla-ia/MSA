import { useEffect, useState, useCallback } from 'react';
import { supabase } from '../lib/supabase';
import { Bar } from 'react-chartjs-2';
import { Chart as ChartJS, CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend } from 'chart.js';
import { TrendingUp, TrendingDown, RefreshCw, BarChart2 } from 'lucide-react';

ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend);

// ─── Types ────────────────────────────────────────────────────────────────────
type DREData = {
  receitaBruta: number;
  cancelamentos: number;
  receitaLiquida: number;
  cpv: number;
  taxasResgate: number;
  lucroBruto: number;
  despesasAdmin: number;
  comissoes: number;
  marketing: number;
  despesasFinanceiras: number;
  outrasDespesas: number;
  ebitda: number;
  lucroLiquido: number;
};

type TrendMes = { mes: string; receita: number; custo: number; lucro: number };

const MES_SHORT = ['Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'];
const MES_FULL  = ['Janeiro','Fevereiro','Março','Abril','Maio','Junho','Julho','Agosto','Setembro','Outubro','Novembro','Dezembro'];

function getMeses() {
  const lista = [];
  const now = new Date();
  for (let i = 0; i < 12; i++) {
    const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
    const val = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
    lista.push({ val, label: `${MES_FULL[d.getMonth()]} ${d.getFullYear()}` });
  }
  return lista;
}

const fmtBRL = (v: number) => v.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
const pct = (val: number, base: number) => base > 0 ? ((val / base) * 100).toFixed(1) + '%' : '—';
const sum = (arr: any[], k: string) => (arr || []).reduce((s, r) => s + (Number(r[k]) || 0), 0);

// ─── DRE Row component ────────────────────────────────────────────────────────
function DRERow({
  label, value, base, indent = false, bold = false, total = false, positive = true, sub
}: {
  label: string; value: number; base: number; indent?: boolean; bold?: boolean;
  total?: boolean; positive?: boolean; sub?: string;
}) {
  const isPos = value >= 0;
  const textColor = total ? (isPos ? 'text-green-700' : 'text-red-600') : 'text-slate-700';
  return (
    <div className={`flex items-center justify-between py-2.5 px-4
      ${total ? 'bg-slate-50 border-y border-slate-200 my-1' : 'border-b border-slate-50 hover:bg-slate-25'}
      ${indent ? 'pl-8' : ''}`}>
      <div>
        <span className={`text-sm ${bold || total ? 'font-semibold' : 'font-normal'} ${indent ? 'text-slate-500' : 'text-slate-700'}`}>
          {label}
        </span>
        {sub && <p className="text-xs text-slate-400 mt-0">{sub}</p>}
      </div>
      <div className="text-right">
        <span className={`text-sm font-semibold ${total ? textColor : (positive ? 'text-slate-700' : 'text-red-500')}`}>
          {!positive && value > 0 ? '−' : ''}{fmtBRL(Math.abs(value))}
        </span>
        {base > 0 && (
          <p className="text-xs text-slate-400">{pct(value, base)}</p>
        )}
      </div>
    </div>
  );
}

// ─── Component ────────────────────────────────────────────────────────────────
export default function DRE() {
  const meses = getMeses();
  const [mesSel, setMesSel] = useState(meses[0].val);
  const [loading, setLoading] = useState(true);
  const [dre, setDre] = useState<DREData | null>(null);
  const [drePrev, setDrePrev] = useState<DREData | null>(null);
  const [trend, setTrend] = useState<TrendMes[]>([]);

  const calcDRE = useCallback(async (mes: string): Promise<DREData> => {
    const [ano, m] = mes.split('-').map(Number);
    const inicio = `${mes}-01`;
    const fim = `${mes}-${String(new Date(ano, m, 0).getDate()).padStart(2, '0')}`;

    const [vendasRes, comprasRes, compBonRes, pagRes] = await Promise.all([
      supabase.from('vendas').select('valor_total').gte('data_venda', inicio).lte('data_venda', fim).neq('status', 'cancelada'),
      supabase.from('compras').select('valor_total').gte('data_entrada', inicio).lte('data_entrada', fim),
      supabase.from('compra_bonificada').select('custo_total').gte('data_compra', inicio).lte('data_compra', fim),
      supabase.from('contas_a_pagar')
        .select('valor_parcela, classificacao_contabil_id, classificacao_contabil:classificacao_contabil(classificacao)')
        .gte('data_vencimento', inicio).lte('data_vencimento', fim)
        .not('status_pagamento', 'eq', 'cancelado'),
    ]);

    const receitaBruta = sum(vendasRes.data || [], 'valor_total');
    const cpv = sum(comprasRes.data || [], 'valor_total') + sum(compBonRes.data || [], 'custo_total');

    // Categoriza despesas por classificação
    const pagamentos = pagRes.data || [];
    let despesasAdmin = 0, comissoes = 0, marketing = 0, despesasFinanceiras = 0, taxasResgate = 0, outrasDespesas = 0;

    for (const p of pagamentos) {
      const classe = ((p as any).classificacao_contabil?.classificacao || '').toLowerCase();
      const val = p.valor_parcela || 0;
      if (classe.includes('admin') || classe.includes('operac')) despesasAdmin += val;
      else if (classe.includes('comiss') || classe.includes('venda')) comissoes += val;
      else if (classe.includes('market') || classe.includes('publi')) marketing += val;
      else if (classe.includes('financ') || classe.includes('banco') || classe.includes('juro')) despesasFinanceiras += val;
      else if (classe.includes('taxa') || classe.includes('embark') || classe.includes('resgate')) taxasResgate += val;
      else outrasDespesas += val;
    }

    const cancelamentos = receitaBruta * 0; // sem campo cancelamento ainda
    const receitaLiquida = receitaBruta - cancelamentos;
    const lucroBruto = receitaLiquida - cpv - taxasResgate;
    const totalDespesas = despesasAdmin + comissoes + marketing + despesasFinanceiras + outrasDespesas;
    const ebitda = lucroBruto - totalDespesas;
    const lucroLiquido = ebitda;

    return { receitaBruta, cancelamentos, receitaLiquida, cpv, taxasResgate, lucroBruto, despesasAdmin, comissoes, marketing, despesasFinanceiras, outrasDespesas, ebitda, lucroLiquido };
  }, []);

  const loadTrend = useCallback(async () => {
    const now = new Date();
    const result: TrendMes[] = [];
    for (let i = 5; i >= 0; i--) {
      const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
      const mes = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
      const data = await calcDRE(mes);
      result.push({ mes: MES_SHORT[d.getMonth()], receita: data.receitaBruta, custo: data.cpv, lucro: data.lucroLiquido });
    }
    setTrend(result);
  }, [calcDRE]);

  const loadAll = useCallback(async (mes: string) => {
    setLoading(true);
    try {
      const [ano, m] = mes.split('-').map(Number);
      const mesAnterior = m === 1
        ? `${ano - 1}-12`
        : `${ano}-${String(m - 1).padStart(2, '0')}`;
      const [cur, prev] = await Promise.all([calcDRE(mes), calcDRE(mesAnterior)]);
      setDre(cur);
      setDrePrev(prev);
      await loadTrend();
    } finally {
      setLoading(false);
    }
  }, [calcDRE, loadTrend]);

  useEffect(() => { loadAll(mesSel); }, [mesSel, loadAll]);

  const mesLabel = meses.find(m => m.val === mesSel)?.label || '';

  const varPct = (cur: number, prev: number) => {
    if (!prev) return null;
    const v = ((cur - prev) / Math.abs(prev)) * 100;
    return { val: v, label: `${v >= 0 ? '+' : ''}${v.toFixed(1)}%`, positive: v >= 0 };
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-3">
        <div>
          <h1 className="text-2xl font-bold text-slate-800">DRE — Demonstrativo de Resultado</h1>
          <p className="text-slate-500 text-sm">Resultado do exercício por competência</p>
        </div>
        <div className="flex items-center gap-2">
          <select value={mesSel} onChange={e => setMesSel(e.target.value)}
            className="px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 bg-white">
            {meses.map(m => <option key={m.val} value={m.val}>{m.label}</option>)}
          </select>
          <button onClick={() => loadAll(mesSel)} className="p-2 text-slate-500 hover:text-blue-600 hover:bg-blue-50 rounded-lg">
            <RefreshCw className="w-4 h-4" />
          </button>
        </div>
      </div>

      {/* KPI rápidos */}
      {dre && (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
          {[
            { label: 'Receita Bruta',  value: dre.receitaBruta,  prev: drePrev?.receitaBruta,  accent: 'border-blue-100',   bg: 'bg-blue-50',   icon: TrendingUp,   iconColor: 'text-blue-600',   valColor: 'text-blue-700' },
            { label: 'CPV (Custo)',    value: dre.cpv,            prev: drePrev?.cpv,            accent: 'border-red-100',    bg: 'bg-red-50',    icon: TrendingDown, iconColor: 'text-red-500',    valColor: 'text-red-600' },
            { label: 'Lucro Bruto',   value: dre.lucroBruto,     prev: drePrev?.lucroBruto,     accent: 'border-emerald-100',bg: 'bg-emerald-50',icon: BarChart2,    iconColor: 'text-emerald-600',valColor: 'text-emerald-700' },
            { label: 'Lucro Líquido', value: dre.lucroLiquido,   prev: drePrev?.lucroLiquido,   accent: dre.lucroLiquido >= 0 ? 'border-green-100' : 'border-orange-100',
              bg: dre.lucroLiquido >= 0 ? 'bg-green-50' : 'bg-orange-50',
              icon: dre.lucroLiquido >= 0 ? TrendingUp : TrendingDown,
              iconColor: dre.lucroLiquido >= 0 ? 'text-green-600' : 'text-orange-500',
              valColor: dre.lucroLiquido >= 0 ? 'text-green-700' : 'text-orange-600' },
          ].map((c, i) => {
            const vp = c.prev !== undefined ? varPct(c.value, c.prev) : null;
            return (
              <div key={i} className={`bg-white rounded-xl border shadow-sm p-4 ${c.accent}`}>
                <div className={`inline-flex p-2 rounded-lg mb-3 ${c.bg}`}>
                  <c.icon className={`w-4 h-4 ${c.iconColor}`} />
                </div>
                <p className="text-xs text-slate-500 font-medium mb-1">{c.label}</p>
                {loading ? <div className="h-7 w-24 bg-slate-100 rounded animate-pulse" /> :
                  <p className={`text-xl font-bold ${c.valColor}`}>{fmtBRL(c.value)}</p>}
                {vp && !loading && (
                  <p className={`text-xs mt-0.5 ${vp.positive ? 'text-green-600' : 'text-red-500'}`}>
                    {vp.label} vs mês ant.
                  </p>
                )}
              </div>
            );
          })}
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-5 gap-6">
        {/* DRE Estrutura */}
        <div className="lg:col-span-3 bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
          <div className="px-4 py-3 border-b border-slate-100 flex items-center justify-between">
            <h3 className="font-semibold text-slate-800">Demonstrativo — {mesLabel}</h3>
            {dre && <span className="text-xs text-slate-400">Regime de competência</span>}
          </div>

          {loading ? (
            <div className="p-6 space-y-2">{[...Array(12)].map((_, i) => <div key={i} className="h-8 bg-slate-50 rounded animate-pulse" />)}</div>
          ) : dre ? (
            <div className="py-2">
              <DRERow label="RECEITA OPERACIONAL BRUTA" value={dre.receitaBruta} base={dre.receitaBruta} bold sub="Fonte: vendas do mês" />
              <DRERow label="(-) Cancelamentos / Devoluções" value={dre.cancelamentos} base={dre.receitaBruta} indent positive={false} />
              <DRERow label="= RECEITA LÍQUIDA" value={dre.receitaLiquida} base={dre.receitaBruta} total bold />

              <DRERow label="CUSTO OPERACIONAL" value={dre.cpv + dre.taxasResgate} base={dre.receitaBruta} bold />
              <DRERow label="(-) Custo Aquisição Milhas (CPV)" value={dre.cpv} base={dre.receitaBruta} indent positive={false} sub="Fonte: compras + compra_bonificada" />
              <DRERow label="(-) Taxas Embarque / Resgate" value={dre.taxasResgate} base={dre.receitaBruta} indent positive={false} />
              <DRERow label="= LUCRO BRUTO" value={dre.lucroBruto} base={dre.receitaBruta} total bold />

              <DRERow label="DESPESAS OPERACIONAIS" value={dre.despesasAdmin + dre.comissoes + dre.marketing + dre.despesasFinanceiras + dre.outrasDespesas} base={dre.receitaBruta} bold />
              <DRERow label="(-) Despesas Administrativas" value={dre.despesasAdmin} base={dre.receitaBruta} indent positive={false} />
              <DRERow label="(-) Comissões de Vendas" value={dre.comissoes} base={dre.receitaBruta} indent positive={false} />
              <DRERow label="(-) Marketing / Captação" value={dre.marketing} base={dre.receitaBruta} indent positive={false} />
              <DRERow label="(-) Despesas Financeiras" value={dre.despesasFinanceiras} base={dre.receitaBruta} indent positive={false} />
              {dre.outrasDespesas > 0 && <DRERow label="(-) Outras Despesas" value={dre.outrasDespesas} base={dre.receitaBruta} indent positive={false} />}

              <DRERow label="= EBITDA" value={dre.ebitda} base={dre.receitaBruta} total bold />

              <div className={`flex items-center justify-between py-4 px-4 mx-2 mt-2 rounded-xl ${dre.lucroLiquido >= 0 ? 'bg-green-50 border border-green-200' : 'bg-red-50 border border-red-200'}`}>
                <span className={`text-base font-bold ${dre.lucroLiquido >= 0 ? 'text-green-800' : 'text-red-700'}`}>= LUCRO LÍQUIDO</span>
                <div className="text-right">
                  <p className={`text-xl font-bold ${dre.lucroLiquido >= 0 ? 'text-green-700' : 'text-red-600'}`}>{fmtBRL(dre.lucroLiquido)}</p>
                  <p className={`text-xs ${dre.lucroLiquido >= 0 ? 'text-green-600' : 'text-red-500'}`}>{pct(dre.lucroLiquido, dre.receitaBruta)} margem</p>
                </div>
              </div>
            </div>
          ) : null}
        </div>

        {/* Gráfico */}
        <div className="lg:col-span-2 space-y-4">
          <div className="bg-white rounded-xl border border-slate-200 shadow-sm p-5">
            <h3 className="font-semibold text-slate-800 mb-1">Evolução 6 Meses</h3>
            <p className="text-xs text-slate-400 mb-4">Receita vs Custo vs Lucro</p>
            <div className="h-56">
              {loading ? <div className="h-full bg-slate-50 rounded animate-pulse" /> : (
                <Bar
                  data={{
                    labels: trend.map(t => t.mes),
                    datasets: [
                      { label: 'Receita', data: trend.map(t => t.receita), backgroundColor: '#3b82f6', borderRadius: 3 },
                      { label: 'CPV',     data: trend.map(t => t.custo),   backgroundColor: '#ef4444', borderRadius: 3 },
                      { label: 'Lucro',   data: trend.map(t => t.lucro),   backgroundColor: '#10b981', borderRadius: 3 },
                    ],
                  }}
                  options={{
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { position: 'bottom', labels: { font: { size: 10 } } } },
                    scales: {
                      x: { grid: { display: false }, ticks: { font: { size: 10 } } },
                      y: { grid: { color: 'rgba(0,0,0,0.05)' }, ticks: { font: { size: 9 }, callback: (v: any) => `R$${(v/1000).toFixed(0)}k` } },
                    },
                  }}
                />
              )}
            </div>
          </div>

          {/* Margem rápida */}
          {dre && !loading && (
            <div className="bg-white rounded-xl border border-slate-200 shadow-sm p-5">
              <h3 className="font-semibold text-slate-800 mb-3">Margens — {mesLabel}</h3>
              <div className="space-y-3">
                {[
                  { label: 'Margem Bruta',   value: dre.receitaBruta > 0 ? (dre.lucroBruto / dre.receitaBruta) * 100 : 0,   color: 'bg-emerald-500' },
                  { label: 'Margem EBITDA',  value: dre.receitaBruta > 0 ? (dre.ebitda / dre.receitaBruta) * 100 : 0,         color: 'bg-blue-500' },
                  { label: 'Margem Líquida', value: dre.receitaBruta > 0 ? (dre.lucroLiquido / dre.receitaBruta) * 100 : 0,  color: dre.lucroLiquido >= 0 ? 'bg-green-500' : 'bg-red-500' },
                ].map((m, i) => (
                  <div key={i}>
                    <div className="flex justify-between text-sm mb-1">
                      <span className="text-slate-600">{m.label}</span>
                      <span className="font-semibold text-slate-700">{m.value.toFixed(1)}%</span>
                    </div>
                    <div className="h-2 bg-slate-100 rounded-full overflow-hidden">
                      <div className={`h-full rounded-full ${m.color}`} style={{ width: `${Math.min(Math.max(m.value, 0), 100)}%` }} />
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
