import { useEffect, useState, useCallback, FormEvent } from 'react';
import { supabase } from '../lib/supabase';
import { formatCurrency } from '../lib/formatters';
import { PlusCircle, Pencil, Trash2, RefreshCw, Target } from 'lucide-react';
import Modal from '../components/Modal';
import ConfirmDialog from '../components/ConfirmDialog';

type OrcamentoItem = {
  id: string;
  ano: number;
  mes: number;
  classificacao_contabil_id: string | null;
  centro_custo_id: string | null;
  valor_orcado: number;
  descricao: string | null;
  classificacao?: { classificacao: string; descricao: string } | null;
  centro_custo?: { nome: string } | null;
};

type Classificacao = { id: string; classificacao: string; descricao: string };
type CentroCusto = { id: string; nome: string };

const MES_FULL = ['Janeiro','Fevereiro','Março','Abril','Maio','Junho','Julho','Agosto','Setembro','Outubro','Novembro','Dezembro'];
const fmtBRL = (v: number) => v.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
const sum = (arr: any[], k: string) => (arr || []).reduce((s, r) => s + (Number(r[k]) || 0), 0);

function getAnos() {
  const y = new Date().getFullYear();
  return [y - 1, y, y + 1];
}

export default function Orcamento() {
  const now = new Date();
  const [anoSel, setAnoSel] = useState(now.getFullYear());
  const [mesSel, setMesSel] = useState(now.getMonth() + 1);
  const [items, setItems] = useState<OrcamentoItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [modalOpen, setModalOpen] = useState(false);
  const [editing, setEditing] = useState<OrcamentoItem | null>(null);
  const [classificacoes, setClassificacoes] = useState<Classificacao[]>([]);
  const [centros, setCentros] = useState<CentroCusto[]>([]);
  const [realizadoMes, setRealizadoMes] = useState({ receita: 0, despesa: 0 });
  const [form, setForm] = useState<Partial<OrcamentoItem>>({
    ano: now.getFullYear(), mes: now.getMonth() + 1,
    valor_orcado: 0, descricao: ''
  });
  const [dialog, setDialog] = useState<{
    isOpen: boolean; type: 'info' | 'warning' | 'error' | 'success' | 'confirm';
    title: string; message: string; onConfirm?: () => void;
  }>({ isOpen: false, type: 'info', title: '', message: '' });

  const loadData = useCallback(async () => {
    setLoading(true);
    const inicio = `${anoSel}-${String(mesSel).padStart(2, '0')}-01`;
    const fim = `${anoSel}-${String(mesSel).padStart(2, '0')}-${String(new Date(anoSel, mesSel, 0).getDate()).padStart(2, '0')}`;

    const [orcRes, classRes, centroRes, vendasRes, comprasRes, pagRes] = await Promise.all([
      supabase.from('orcamento')
        .select('*, classificacao:classificacao_contabil(classificacao,descricao), centro_custo:centro_custos(nome)')
        .eq('ano', anoSel).eq('mes', mesSel).order('created_at'),
      supabase.from('classificacao_contabil').select('id, classificacao, descricao').order('classificacao'),
      supabase.from('centro_custos').select('id, nome').order('nome'),
      supabase.from('vendas').select('valor_total').gte('data_venda', inicio).lte('data_venda', fim).neq('status', 'cancelada'),
      supabase.from('compras').select('valor_total').gte('data_entrada', inicio).lte('data_entrada', fim),
      supabase.from('contas_a_pagar').select('valor_parcela').gte('data_vencimento', inicio).lte('data_vencimento', fim).not('status_pagamento', 'eq', 'cancelado'),
    ]);

    setItems(orcRes.data || []);
    setClassificacoes(classRes.data || []);
    setCentros(centroRes.data || []);
    setRealizadoMes({
      receita: sum(vendasRes.data || [], 'valor_total'),
      despesa: sum(comprasRes.data || [], 'valor_total') + sum(pagRes.data || [], 'valor_parcela'),
    });
    setLoading(false);
  }, [anoSel, mesSel]);

  useEffect(() => { loadData(); }, [loadData]);

  const openAdd = () => {
    setEditing(null);
    setForm({ ano: anoSel, mes: mesSel, valor_orcado: 0, descricao: '', classificacao_contabil_id: null, centro_custo_id: null });
    setModalOpen(true);
  };
  const openEdit = (item: OrcamentoItem) => { setEditing(item); setForm({ ...item }); setModalOpen(true); };

  const handleDelete = (item: OrcamentoItem) => {
    setDialog({
      isOpen: true, type: 'warning', title: 'Confirmar Exclusão',
      message: 'Excluir este item do orçamento?',
      onConfirm: async () => {
        await supabase.from('orcamento').delete().eq('id', item.id);
        loadData();
        setDialog({ isOpen: true, type: 'success', title: 'Sucesso', message: 'Item excluído.' });
      }
    });
  };

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    try {
      const payload = {
        ano: form.ano || anoSel,
        mes: form.mes || mesSel,
        classificacao_contabil_id: form.classificacao_contabil_id || null,
        centro_custo_id: form.centro_custo_id || null,
        valor_orcado: Number(form.valor_orcado) || 0,
        descricao: form.descricao || null,
        updated_at: new Date().toISOString(),
      };
      if (editing) {
        const { error } = await supabase.from('orcamento').update(payload).eq('id', editing.id);
        if (error) throw error;
      } else {
        const { error } = await supabase.from('orcamento').insert(payload);
        if (error) throw error;
      }
      setModalOpen(false);
      loadData();
      setDialog({ isOpen: true, type: 'success', title: 'Sucesso', message: editing ? 'Item atualizado!' : 'Item criado!' });
    } catch (err: any) {
      setDialog({ isOpen: true, type: 'error', title: 'Erro', message: err.message });
    }
  };

  const totalOrcado = items.reduce((s, i) => s + i.valor_orcado, 0);
  const totalRealizado = realizadoMes.receita - realizadoMes.despesa;
  const variacao = totalRealizado - totalOrcado;

  return (
    <>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between flex-wrap gap-3">
          <div>
            <h1 className="text-2xl font-bold text-slate-800">Orçamento</h1>
            <p className="text-slate-500 text-sm">Metas financeiras vs resultados realizados</p>
          </div>
          <button onClick={openAdd} className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 text-sm font-medium">
            <PlusCircle className="w-4 h-4" /> Nova Meta
          </button>
        </div>

        {/* Filtros */}
        <div className="flex items-center gap-3 flex-wrap">
          <select value={anoSel} onChange={e => setAnoSel(Number(e.target.value))}
            className="px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 bg-white">
            {getAnos().map(a => <option key={a} value={a}>{a}</option>)}
          </select>
          <select value={mesSel} onChange={e => setMesSel(Number(e.target.value))}
            className="px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 bg-white">
            {MES_FULL.map((m, i) => <option key={i + 1} value={i + 1}>{m}</option>)}
          </select>
          <button onClick={loadData} className="p-2 text-slate-500 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors">
            <RefreshCw className="w-4 h-4" />
          </button>
        </div>

        {/* KPIs resumo */}
        <div className="grid grid-cols-3 gap-4">
          {[
            { label: 'Total Orçado',    value: fmtBRL(totalOrcado),   border: 'border-blue-100',   bg: 'bg-blue-50',   icon: 'text-blue-600', val: 'text-blue-700' },
            { label: 'Realizado (líq)', value: fmtBRL(totalRealizado), border: 'border-emerald-100', bg: 'bg-emerald-50', icon: 'text-emerald-600', val: 'text-emerald-700' },
            { label: 'Variação',        value: fmtBRL(variacao),       border: variacao >= 0 ? 'border-green-100' : 'border-red-100', bg: variacao >= 0 ? 'bg-green-50' : 'bg-red-50', icon: variacao >= 0 ? 'text-green-600' : 'text-red-500', val: variacao >= 0 ? 'text-green-700' : 'text-red-600' },
          ].map((c, i) => (
            <div key={i} className={`bg-white rounded-xl border shadow-sm p-4 ${c.border}`}>
              <div className={`inline-flex p-2 rounded-lg mb-2 ${c.bg}`}>
                <Target className={`w-4 h-4 ${c.icon}`} />
              </div>
              <p className="text-xs text-slate-500 font-medium">{c.label}</p>
              {loading ? <div className="h-7 w-24 bg-slate-100 rounded animate-pulse mt-1" /> :
                <p className={`text-xl font-bold mt-0.5 ${c.val}`}>{c.value}</p>}
            </div>
          ))}
        </div>

        {/* Realizado vs Orçado */}
        {!loading && (
          <div className="bg-white rounded-xl border border-slate-200 shadow-sm p-5">
            <h3 className="font-semibold text-slate-800 mb-4">Realizado vs Orçado — {MES_FULL[mesSel - 1]} {anoSel}</h3>
            <div className="grid grid-cols-2 gap-6">
              <div>
                <div className="flex justify-between text-sm mb-2">
                  <span className="text-slate-600">Receita Realizada</span>
                  <span className="font-semibold text-green-600">{fmtBRL(realizadoMes.receita)}</span>
                </div>
                <div className="h-2.5 bg-slate-100 rounded-full overflow-hidden">
                  <div className="h-full bg-green-500 rounded-full" style={{ width: `${totalOrcado > 0 ? Math.min((realizadoMes.receita / totalOrcado) * 100, 100) : 0}%` }} />
                </div>
              </div>
              <div>
                <div className="flex justify-between text-sm mb-2">
                  <span className="text-slate-600">Despesas Realizadas</span>
                  <span className="font-semibold text-red-500">{fmtBRL(realizadoMes.despesa)}</span>
                </div>
                <div className="h-2.5 bg-slate-100 rounded-full overflow-hidden">
                  <div className="h-full bg-red-500 rounded-full" style={{ width: `${totalOrcado > 0 ? Math.min((realizadoMes.despesa / totalOrcado) * 100, 100) : 0}%` }} />
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Tabela de itens */}
        <div className="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
          <div className="px-5 py-4 border-b border-slate-100">
            <h3 className="font-semibold text-slate-800">Itens do Orçamento — {MES_FULL[mesSel - 1]} {anoSel}</h3>
          </div>
          {loading ? (
            <div className="p-6 space-y-3">{[...Array(4)].map((_, i) => <div key={i} className="h-12 bg-slate-50 rounded animate-pulse" />)}</div>
          ) : items.length === 0 ? (
            <div className="py-14 text-center">
              <Target className="w-10 h-10 text-slate-200 mx-auto mb-2" />
              <p className="text-slate-400 text-sm">Nenhuma meta cadastrada para este período</p>
              <button onClick={openAdd} className="mt-3 px-4 py-2 text-blue-600 hover:bg-blue-50 rounded-lg text-sm transition-colors">
                + Adicionar primeira meta
              </button>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead className="border-b border-slate-100 bg-slate-50">
                  <tr>
                    {['Classificação', 'Centro de Custo', 'Descrição', 'Valor Orçado', 'Ações'].map(h => (
                      <th key={h} className="px-4 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wide">{h}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {items.map(item => (
                    <tr key={item.id} className="border-b border-slate-50 hover:bg-slate-50 transition-colors">
                      <td className="px-4 py-3 text-slate-600 text-xs">
                        {item.classificacao ? `${item.classificacao.classificacao} — ${item.classificacao.descricao}` : '—'}
                      </td>
                      <td className="px-4 py-3 text-slate-600 text-xs">{item.centro_custo?.nome || '—'}</td>
                      <td className="px-4 py-3 text-slate-700">{item.descricao || '—'}</td>
                      <td className="px-4 py-3 font-semibold text-blue-700">{fmtBRL(item.valor_orcado)}</td>
                      <td className="px-4 py-3">
                        <div className="flex items-center gap-1">
                          <button onClick={() => openEdit(item)} className="p-1.5 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded transition-colors">
                            <Pencil className="w-3.5 h-3.5" />
                          </button>
                          <button onClick={() => handleDelete(item)} className="p-1.5 text-slate-400 hover:text-red-500 hover:bg-red-50 rounded transition-colors">
                            <Trash2 className="w-3.5 h-3.5" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                  <tr className="bg-slate-50 border-t border-slate-200">
                    <td colSpan={3} className="px-4 py-3 text-xs font-semibold text-slate-500 uppercase tracking-wide">Total Orçado</td>
                    <td className="px-4 py-3 font-bold text-blue-700">{fmtBRL(totalOrcado)}</td>
                    <td />
                  </tr>
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>

      {/* Modal */}
      <Modal isOpen={modalOpen} onClose={() => setModalOpen(false)} title={editing ? 'Editar Meta' : 'Nova Meta de Orçamento'}>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Ano</label>
              <select value={form.ano || anoSel} onChange={e => setForm({ ...form, ano: Number(e.target.value) })}
                className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm">
                {getAnos().map(a => <option key={a} value={a}>{a}</option>)}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Mês</label>
              <select value={form.mes || mesSel} onChange={e => setForm({ ...form, mes: Number(e.target.value) })}
                className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm">
                {MES_FULL.map((m, i) => <option key={i + 1} value={i + 1}>{m}</option>)}
              </select>
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Classificação Contábil</label>
            <select value={form.classificacao_contabil_id || ''} onChange={e => setForm({ ...form, classificacao_contabil_id: e.target.value || null })}
              className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm">
              <option value="">Nenhuma</option>
              {classificacoes.map(c => <option key={c.id} value={c.id}>{c.classificacao} — {c.descricao}</option>)}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Centro de Custo</label>
            <select value={form.centro_custo_id || ''} onChange={e => setForm({ ...form, centro_custo_id: e.target.value || null })}
              className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm">
              <option value="">Nenhum</option>
              {centros.map(c => <option key={c.id} value={c.id}>{c.nome}</option>)}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Valor Orçado (R$) <span className="text-red-500">*</span></label>
            <input type="number" step="0.01" min="0" required value={form.valor_orcado || ''} onChange={e => setForm({ ...form, valor_orcado: Number(e.target.value) })}
              className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm" />
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Descrição</label>
            <input value={form.descricao || ''} onChange={e => setForm({ ...form, descricao: e.target.value })}
              placeholder="Ex: Meta de receita operacional" className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm" />
          </div>
          <div className="flex justify-end gap-3 pt-2">
            <button type="button" onClick={() => setModalOpen(false)} className="px-4 py-2 text-slate-700 border border-slate-300 rounded-lg hover:bg-slate-50 text-sm">Cancelar</button>
            <button type="submit" className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 text-sm font-medium">{editing ? 'Atualizar' : 'Criar'}</button>
          </div>
        </form>
      </Modal>

      <ConfirmDialog isOpen={dialog.isOpen} type={dialog.type} title={dialog.title} message={dialog.message}
        onClose={() => setDialog({ ...dialog, isOpen: false })} onConfirm={dialog.onConfirm} />
    </>
  );
}
