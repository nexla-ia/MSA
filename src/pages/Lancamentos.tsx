import { useEffect, useState, useCallback, FormEvent } from 'react';
import { supabase } from '../lib/supabase';
import { useAuth } from '../contexts/AuthContext';
import { formatCurrency, formatDate } from '../lib/formatters';
import Modal from '../components/Modal';
import ConfirmDialog from '../components/ConfirmDialog';
import {
  PlusCircle, Search, ArrowDownCircle, ArrowUpCircle,
  Pencil, Trash2, RefreshCw, FileText
} from 'lucide-react';

type Lancamento = {
  id: string;
  data_lancamento: string;
  descricao: string;
  valor: number;
  tipo: 'entrada' | 'saida';
  categoria: string | null;
  conta_bancaria_id: string | null;
  classificacao_contabil_id: string | null;
  centro_custo_id: string | null;
  conciliado: boolean;
  observacao: string | null;
  conta_bancaria?: { nome_banco: string } | null;
  classificacao?: { classificacao: string } | null;
  centro_custo?: { nome: string } | null;
};

type ContaBancaria = { id: string; nome_banco: string };
type Classificacao = { id: string; classificacao: string; descricao: string };
type CentroCusto = { id: string; nome: string };

const emptyForm = (): Partial<Lancamento> => ({
  data_lancamento: new Date().toISOString().split('T')[0],
  descricao: '',
  valor: 0,
  tipo: 'entrada',
  categoria: '',
  conta_bancaria_id: null,
  classificacao_contabil_id: null,
  centro_custo_id: null,
  observacao: '',
});

const fmtBRL = (v: number) => v.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });

export default function Lancamentos() {
  const { usuario } = useAuth();
  const [lancamentos, setLancamentos] = useState<Lancamento[]>([]);
  const [loading, setLoading] = useState(true);
  const [modalOpen, setModalOpen] = useState(false);
  const [editing, setEditing] = useState<Lancamento | null>(null);
  const [form, setForm] = useState<Partial<Lancamento>>(emptyForm());
  const [busca, setBusca] = useState('');
  const [filtroTipo, setFiltroTipo] = useState<'todos' | 'entrada' | 'saida'>('todos');
  const [contas, setContas] = useState<ContaBancaria[]>([]);
  const [classificacoes, setClassificacoes] = useState<Classificacao[]>([]);
  const [centros, setCentros] = useState<CentroCusto[]>([]);
  const [dialog, setDialog] = useState<{
    isOpen: boolean; type: 'info' | 'warning' | 'error' | 'success' | 'confirm';
    title: string; message: string; onConfirm?: () => void;
  }>({ isOpen: false, type: 'info', title: '', message: '' });

  const loadData = useCallback(async () => {
    setLoading(true);
    const [lancRes, contasRes, classRes, centroRes] = await Promise.all([
      supabase.from('lancamentos_financeiros')
        .select('*, conta_bancaria:contas_bancarias(nome_banco), classificacao:classificacao_contabil(classificacao), centro_custo:centro_custos(nome)')
        .order('data_lancamento', { ascending: false })
        .limit(200),
      supabase.from('contas_bancarias').select('id, nome_banco').order('nome_banco'),
      supabase.from('classificacao_contabil').select('id, classificacao, descricao').order('classificacao'),
      supabase.from('centro_custos').select('id, nome').order('nome'),
    ]);
    setLancamentos(lancRes.data || []);
    setContas(contasRes.data || []);
    setClassificacoes(classRes.data || []);
    setCentros(centroRes.data || []);
    setLoading(false);
  }, []);

  useEffect(() => { loadData(); }, [loadData]);

  const openAdd = () => { setEditing(null); setForm(emptyForm()); setModalOpen(true); };
  const openEdit = (l: Lancamento) => { setEditing(l); setForm({ ...l }); setModalOpen(true); };

  const handleDelete = (l: Lancamento) => {
    setDialog({
      isOpen: true, type: 'warning',
      title: 'Confirmar Exclusão',
      message: `Excluir lançamento "${l.descricao}"?`,
      onConfirm: async () => {
        await supabase.from('lancamentos_financeiros').delete().eq('id', l.id);
        loadData();
        setDialog({ isOpen: true, type: 'success', title: 'Sucesso', message: 'Lançamento excluído.' });
      }
    });
  };

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    try {
      const payload = {
        data_lancamento: form.data_lancamento,
        descricao: form.descricao,
        valor: Number(form.valor),
        tipo: form.tipo,
        categoria: form.categoria || null,
        conta_bancaria_id: form.conta_bancaria_id || null,
        classificacao_contabil_id: form.classificacao_contabil_id || null,
        centro_custo_id: form.centro_custo_id || null,
        observacao: form.observacao || null,
        updated_at: new Date().toISOString(),
      };
      if (editing) {
        const { error } = await supabase.from('lancamentos_financeiros').update(payload).eq('id', editing.id);
        if (error) throw error;
      } else {
        const { error } = await supabase.from('lancamentos_financeiros').insert({ ...payload, created_by: usuario?.id });
        if (error) throw error;
      }
      setModalOpen(false);
      loadData();
      setDialog({ isOpen: true, type: 'success', title: 'Sucesso', message: editing ? 'Lançamento atualizado!' : 'Lançamento criado!' });
    } catch (err: any) {
      setDialog({ isOpen: true, type: 'error', title: 'Erro', message: err.message });
    }
  };

  const filtered = lancamentos.filter(l => {
    const matchBusca = !busca || l.descricao.toLowerCase().includes(busca.toLowerCase());
    const matchTipo = filtroTipo === 'todos' || l.tipo === filtroTipo;
    return matchBusca && matchTipo;
  });

  const totalEntradas = filtered.filter(l => l.tipo === 'entrada').reduce((s, l) => s + l.valor, 0);
  const totalSaidas = filtered.filter(l => l.tipo === 'saida').reduce((s, l) => s + l.valor, 0);

  return (
    <>
      <div className="space-y-6">
        <div className="flex items-center justify-between flex-wrap gap-3">
          <div>
            <h1 className="text-2xl font-bold text-slate-800">Lançamentos Financeiros</h1>
            <p className="text-slate-500 text-sm">Razão geral de movimentações financeiras</p>
          </div>
          <button onClick={openAdd} className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 text-sm font-medium">
            <PlusCircle className="w-4 h-4" /> Novo Lançamento
          </button>
        </div>

        {/* Totais */}
        <div className="grid grid-cols-3 gap-4">
          {[
            { label: 'Total Entradas', value: fmtBRL(totalEntradas), icon: ArrowDownCircle, color: 'border-green-100 text-green-700 bg-green-50' },
            { label: 'Total Saídas',   value: fmtBRL(totalSaidas),   icon: ArrowUpCircle,  color: 'border-red-100 text-red-600 bg-red-50' },
            { label: 'Resultado',      value: fmtBRL(totalEntradas - totalSaidas), icon: FileText,
              color: totalEntradas >= totalSaidas ? 'border-emerald-100 text-emerald-700 bg-emerald-50' : 'border-orange-100 text-orange-700 bg-orange-50' },
          ].map((c, i) => (
            <div key={i} className={`bg-white rounded-xl border shadow-sm p-4 ${c.color.split(' ')[0]}`}>
              <div className={`inline-flex p-2 rounded-lg mb-2 ${c.color.split(' ')[2]}`}>
                <c.icon className={`w-4 h-4 ${c.color.split(' ')[1]}`} />
              </div>
              <p className="text-xs text-slate-500 font-medium">{c.label}</p>
              <p className={`text-xl font-bold ${c.color.split(' ')[1]}`}>{c.value}</p>
            </div>
          ))}
        </div>

        {/* Filtros */}
        <div className="bg-white rounded-xl border border-slate-200 shadow-sm p-4 flex flex-wrap gap-3">
          <div className="flex items-center gap-2 flex-1 min-w-48 border border-slate-300 rounded-lg px-3 py-2">
            <Search className="w-4 h-4 text-slate-400" />
            <input value={busca} onChange={e => setBusca(e.target.value)}
              placeholder="Buscar por descrição..." className="flex-1 text-sm outline-none" />
          </div>
          <select value={filtroTipo} onChange={e => setFiltroTipo(e.target.value as any)}
            className="px-3 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 bg-white">
            <option value="todos">Todos</option>
            <option value="entrada">Entradas</option>
            <option value="saida">Saídas</option>
          </select>
          <button onClick={loadData} className="p-2 text-slate-500 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors">
            <RefreshCw className="w-4 h-4" />
          </button>
        </div>

        {/* Tabela */}
        <div className="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
          {loading ? (
            <div className="p-8 space-y-3">{[...Array(5)].map((_, i) => <div key={i} className="h-12 bg-slate-50 rounded animate-pulse" />)}</div>
          ) : filtered.length === 0 ? (
            <div className="py-16 text-center">
              <FileText className="w-10 h-10 text-slate-200 mx-auto mb-2" />
              <p className="text-slate-400 text-sm">Nenhum lançamento encontrado</p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead className="border-b border-slate-100 bg-slate-50">
                  <tr>
                    {['Data', 'Descrição', 'Tipo', 'Valor', 'Classificação', 'Conta', 'Conciliado', 'Ações'].map(h => (
                      <th key={h} className="px-4 py-3 text-left text-xs font-medium text-slate-500 uppercase tracking-wide">{h}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {filtered.map(l => (
                    <tr key={l.id} className="border-b border-slate-50 hover:bg-slate-50 transition-colors">
                      <td className="px-4 py-3 text-slate-500 text-xs whitespace-nowrap">{formatDate(l.data_lancamento)}</td>
                      <td className="px-4 py-3 text-slate-700 max-w-xs truncate">{l.descricao}</td>
                      <td className="px-4 py-3">
                        <span className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-medium
                          ${l.tipo === 'entrada' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
                          {l.tipo === 'entrada' ? <ArrowDownCircle className="w-3 h-3" /> : <ArrowUpCircle className="w-3 h-3" />}
                          {l.tipo === 'entrada' ? 'Entrada' : 'Saída'}
                        </span>
                      </td>
                      <td className={`px-4 py-3 font-semibold ${l.tipo === 'entrada' ? 'text-green-600' : 'text-red-500'}`}>
                        {fmtBRL(l.valor)}
                      </td>
                      <td className="px-4 py-3 text-slate-500 text-xs">{l.classificacao?.classificacao || '—'}</td>
                      <td className="px-4 py-3 text-slate-500 text-xs">{l.conta_bancaria?.nome_banco || '—'}</td>
                      <td className="px-4 py-3">
                        <span className={`px-2 py-0.5 rounded-full text-xs font-medium
                          ${l.conciliado ? 'bg-green-100 text-green-700' : 'bg-slate-100 text-slate-500'}`}>
                          {l.conciliado ? 'Sim' : 'Não'}
                        </span>
                      </td>
                      <td className="px-4 py-3">
                        <div className="flex items-center gap-1">
                          <button onClick={() => openEdit(l)} className="p-1.5 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded transition-colors">
                            <Pencil className="w-3.5 h-3.5" />
                          </button>
                          <button onClick={() => handleDelete(l)} className="p-1.5 text-slate-400 hover:text-red-500 hover:bg-red-50 rounded transition-colors">
                            <Trash2 className="w-3.5 h-3.5" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>

      {/* Modal */}
      <Modal isOpen={modalOpen} onClose={() => setModalOpen(false)} title={editing ? 'Editar Lançamento' : 'Novo Lançamento'}>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Data <span className="text-red-500">*</span></label>
              <input type="date" required value={form.data_lancamento || ''} onChange={e => setForm({ ...form, data_lancamento: e.target.value })}
                className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm" />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Tipo <span className="text-red-500">*</span></label>
              <select required value={form.tipo || 'entrada'} onChange={e => setForm({ ...form, tipo: e.target.value as any })}
                className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm">
                <option value="entrada">Entrada</option>
                <option value="saida">Saída</option>
              </select>
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-slate-700 mb-1">Descrição <span className="text-red-500">*</span></label>
            <input required value={form.descricao || ''} onChange={e => setForm({ ...form, descricao: e.target.value })}
              placeholder="Ex: Pagamento fornecedor" className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm" />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Valor (R$) <span className="text-red-500">*</span></label>
              <input type="number" step="0.01" min="0" required value={form.valor || ''} onChange={e => setForm({ ...form, valor: Number(e.target.value) })}
                className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm" />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Categoria</label>
              <input value={form.categoria || ''} onChange={e => setForm({ ...form, categoria: e.target.value })}
                placeholder="Ex: Receita de Vendas" className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm" />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Conta Bancária</label>
              <select value={form.conta_bancaria_id || ''} onChange={e => setForm({ ...form, conta_bancaria_id: e.target.value || null })}
                className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm">
                <option value="">Nenhuma</option>
                {contas.map(c => <option key={c.id} value={c.id}>{c.nome_banco}</option>)}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">Classificação Contábil</label>
              <select value={form.classificacao_contabil_id || ''} onChange={e => setForm({ ...form, classificacao_contabil_id: e.target.value || null })}
                className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm">
                <option value="">Nenhuma</option>
                {classificacoes.map(c => <option key={c.id} value={c.id}>{c.classificacao} — {c.descricao}</option>)}
              </select>
            </div>
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
            <label className="block text-sm font-medium text-slate-700 mb-1">Observação</label>
            <textarea rows={2} value={form.observacao || ''} onChange={e => setForm({ ...form, observacao: e.target.value })}
              className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm resize-none" />
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
