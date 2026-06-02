# ============================================
# GICA SABORES - Script de instalacao
# Execute no terminal do VS Code (PowerShell)
# ============================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  GICA SABORES - Gerando arquivos..." -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

# ── 1. setup_supabase.sql ──────────────────
$sql = @'
create table if not exists pedidos (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default now(),
  cliente text not null,
  telefone text,
  items jsonb not null,
  total numeric not null,
  status text not null default 'pendente',
  pagamento text not null default 'pix',
  data_pedido date not null default current_date,
  data_entrega date,
  obs text default '',
  reagendado_para date
);

alter table pedidos enable row level security;

create policy "insert_pedidos" on pedidos for insert with check (true);
create policy "select_pedidos" on pedidos for select using (true);
create policy "update_pedidos" on pedidos for update using (true);
create policy "delete_pedidos" on pedidos for delete using (true);
'@
$sql | Out-File -FilePath "setup_supabase.sql" -Encoding UTF8
Write-Host "[OK] setup_supabase.sql criado" -ForegroundColor Green

# ── 2. Cardapio GICA.html ──────────────────
$cardapio = @'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>GICA Sabores - Cardapio</title>
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<style>
@import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Lato:wght@300;400;700&display=swap');
:root{--gold:#C9A84C;--gold-light:#F5E6C0;--gold-dark:#8B6914;--brown:#5C3D1E;--cream:#FDF8F0;--dark:#2C1810;}
*{box-sizing:border-box;margin:0;padding:0;}
body{font-family:'Lato',sans-serif;background:var(--cream);color:var(--dark);}
.header{background:linear-gradient(135deg,var(--brown),var(--dark));padding:2rem 1rem 1.5rem;text-align:center;position:relative;overflow:hidden;}
.header::before{content:'';position:absolute;inset:0;background:url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='%23C9A84C' fill-opacity='0.08'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/svg%3E");}
.header-content{position:relative;}
.logo-circle{width:80px;height:80px;border-radius:50%;background:linear-gradient(135deg,var(--gold),var(--gold-dark));margin:0 auto 1rem;display:flex;align-items:center;justify-content:center;font-size:36px;box-shadow:0 4px 20px rgba(201,168,76,0.4);}
.header h1{font-family:'Playfair Display',serif;color:var(--gold);font-size:2rem;letter-spacing:2px;}
.header p{color:rgba(255,255,255,0.7);font-size:.85rem;margin-top:4px;letter-spacing:1px;text-transform:uppercase;}
.search-bar{padding:1rem;background:white;border-bottom:1px solid var(--gold-light);}
.search-bar input{width:100%;padding:10px 16px;border:1px solid var(--gold-light);border-radius:25px;font-size:14px;outline:none;background:var(--cream);color:var(--dark);}
.search-bar input:focus{border-color:var(--gold);}
.categories{display:flex;gap:8px;padding:1rem;overflow-x:auto;background:white;border-bottom:1px solid var(--gold-light);scrollbar-width:none;}
.categories::-webkit-scrollbar{display:none;}
.cat-btn{padding:6px 16px;border-radius:20px;border:1px solid var(--gold-light);background:white;color:var(--brown);font-size:13px;cursor:pointer;white-space:nowrap;transition:all .2s;font-family:'Lato',sans-serif;}
.cat-btn.active{background:var(--gold);border-color:var(--gold);color:white;}
.products{padding:1rem;max-width:600px;margin:0 auto;}
.category-title{font-family:'Playfair Display',serif;font-size:1.2rem;color:var(--brown);margin:1.5rem 0 .75rem;padding-bottom:6px;border-bottom:2px solid var(--gold-light);}
.product-card{background:white;border-radius:12px;padding:14px;margin-bottom:10px;display:flex;align-items:center;justify-content:space-between;box-shadow:0 2px 8px rgba(0,0,0,.06);border:1px solid transparent;transition:all .2s;}
.product-card:hover{border-color:var(--gold-light);}
.product-info{flex:1;}
.product-name{font-weight:700;font-size:14px;color:var(--dark);}
.product-desc{font-size:12px;color:#888;margin-top:2px;}
.product-price{font-weight:700;color:var(--gold-dark);font-size:15px;margin-top:4px;}
.qty-control{display:flex;align-items:center;gap:8px;flex-shrink:0;}
.qty-btn{width:28px;height:28px;border-radius:50%;border:none;cursor:pointer;font-size:16px;font-weight:700;transition:all .15s;}
.qty-btn.minus{background:var(--gold-light);color:var(--gold-dark);}
.qty-btn.plus{background:var(--gold);color:white;}
.qty-btn:hover{transform:scale(1.1);}
.qty-num{font-weight:700;font-size:15px;min-width:20px;text-align:center;color:var(--dark);}
.cart-bar{position:fixed;bottom:0;left:0;right:0;padding:1rem;background:white;border-top:2px solid var(--gold-light);transform:translateY(100%);transition:transform .3s;z-index:50;box-shadow:0 -4px 20px rgba(0,0,0,.1);}
.cart-bar.visible{transform:translateY(0);}
.cart-btn{width:100%;max-width:500px;margin:0 auto;display:flex;align-items:center;justify-content:space-between;background:linear-gradient(135deg,var(--brown),var(--dark));color:white;border:none;border-radius:25px;padding:14px 20px;cursor:pointer;font-family:'Lato',sans-serif;font-size:15px;font-weight:700;transition:transform .15s;}
.cart-btn:hover{transform:scale(1.02);}
.cart-count{background:var(--gold);color:white;width:24px;height:24px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:700;}
.modal{display:none;position:fixed;inset:0;z-index:100;}
.modal.open{display:flex;}
.modal-bg{position:absolute;inset:0;background:rgba(0,0,0,.55);}
.modal-box{position:relative;background:var(--cream);width:100%;max-width:500px;margin:auto;border-radius:20px 20px 0 0;max-height:92vh;overflow-y:auto;padding:1.5rem;animation:slideUp .3s ease;}
@keyframes slideUp{from{transform:translateY(100%)}to{transform:translateY(0)}}
.modal-title{font-family:'Playfair Display',serif;font-size:1.3rem;color:var(--brown);margin-bottom:1rem;}
.section-label{font-size:11px;font-weight:700;color:var(--brown);text-transform:uppercase;letter-spacing:.5px;margin:1.2rem 0 .6rem;display:flex;align-items:center;gap:6px;}
.section-label::after{content:'';flex:1;height:1px;background:var(--gold-light);}
.cart-item{display:flex;justify-content:space-between;align-items:center;padding:8px 0;border-bottom:1px solid var(--gold-light);font-size:14px;}
.cart-item-name{color:var(--dark);font-weight:600;}
.cart-item-detail{color:#888;font-size:12px;}
.cart-item-price{font-weight:700;color:var(--gold-dark);white-space:nowrap;}
.cart-total-row{display:flex;justify-content:space-between;font-size:17px;font-weight:700;padding:12px 0 4px;color:var(--dark);border-top:2px solid var(--gold);}
.form-group{margin-bottom:12px;}
.form-label{font-size:12px;font-weight:700;color:var(--brown);display:block;margin-bottom:5px;}
.form-input{width:100%;padding:11px 14px;border:1px solid var(--gold-light);border-radius:10px;font-size:14px;background:white;color:var(--dark);outline:none;font-family:'Lato',sans-serif;}
.form-input:focus{border-color:var(--gold);}
.form-row{display:grid;grid-template-columns:1fr 1fr;gap:10px;}
.pay-grid{display:grid;grid-template-columns:1fr 1fr;gap:8px;}
.pay-opt{padding:10px 8px;border:2px solid var(--gold-light);border-radius:10px;text-align:center;cursor:pointer;transition:all .2s;font-size:13px;font-weight:700;color:var(--brown);background:white;}
.pay-opt.selected{border-color:var(--gold);background:var(--gold-light);color:var(--gold-dark);}
.send-btn{width:100%;padding:15px;background:linear-gradient(135deg,#25D366,#128C7E);color:white;border:none;border-radius:25px;font-size:16px;font-weight:700;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:10px;font-family:'Lato',sans-serif;margin-top:1.2rem;transition:transform .15s;}
.send-btn:hover{transform:scale(1.02);}
.send-btn:disabled{opacity:.5;cursor:not-allowed;transform:none;}
.success-screen{display:none;text-align:center;padding:2.5rem 1rem;}
.success-screen .big{font-size:4rem;margin-bottom:1rem;}
.success-screen h2{font-family:'Playfair Display',serif;color:var(--brown);margin-bottom:.5rem;}
.success-screen p{color:#888;font-size:14px;line-height:1.6;}
.novo-btn{display:inline-block;margin-top:1.5rem;padding:12px 28px;background:linear-gradient(135deg,var(--brown),var(--dark));color:white;border:none;border-radius:25px;font-size:15px;font-weight:700;cursor:pointer;font-family:'Lato',sans-serif;}
.empty-state{text-align:center;padding:1rem;color:#aaa;font-size:14px;}
</style>
</head>
<body>

<div class="header">
  <div class="header-content">
    <div class="logo-circle">🎂</div>
    <h1>GICA Sabores</h1>
    <p>Feito com amor e capricho</p>
  </div>
</div>

<div class="search-bar">
  <input type="text" id="search" placeholder="🔍  Buscar produto..." oninput="renderProdutos()">
</div>
<div class="categories" id="categories"></div>
<div class="products" id="products-list"></div>
<div style="height:90px"></div>

<div class="cart-bar" id="cart-bar">
  <button class="cart-btn" onclick="abrirModal()">
    <span>🛒 Finalizar pedido</span>
    <div style="display:flex;align-items:center;gap:8px">
      <span id="cart-total-bar">R$ 0,00</span>
      <div class="cart-count" id="cart-count">0</div>
    </div>
  </button>
</div>

<div class="modal" id="modal">
  <div class="modal-bg" onclick="fecharModal()"></div>
  <div class="modal-box">

    <!-- TELA PEDIDO -->
    <div id="tela-pedido">
      <div class="modal-title">🛒 Seu Pedido</div>

      <div class="section-label">Itens selecionados</div>
      <div id="cart-items-list"></div>
      <div class="cart-total-row">
        <span>Total</span>
        <span id="cart-total-modal">R$ 0,00</span>
      </div>

      <div class="section-label">Seus dados</div>
      <div class="form-group">
        <label class="form-label">Nome completo *</label>
        <input class="form-input" id="f-nome" placeholder="Como voce se chama?">
      </div>
      <div class="form-group">
        <label class="form-label">WhatsApp *</label>
        <input class="form-input" id="f-tel" placeholder="(11) 99999-9999" type="tel">
      </div>

      <div class="section-label">Entrega e pagamento</div>
      <div class="form-row">
        <div class="form-group">
          <label class="form-label">Data do pedido *</label>
          <input class="form-input" id="f-data-pedido" type="date">
        </div>
        <div class="form-group">
          <label class="form-label">Data de entrega</label>
          <input class="form-input" id="f-data-entrega" type="date">
        </div>
      </div>
      <div class="form-group">
        <label class="form-label">Forma de pagamento *</label>
        <div class="pay-grid">
          <div class="pay-opt selected" onclick="selecionarPag(this,'pix')">💳 Pix</div>
          <div class="pay-opt" onclick="selecionarPag(this,'dinheiro')">💵 Dinheiro</div>
          <div class="pay-opt" onclick="selecionarPag(this,'transferencia')">🏦 Transferencia</div>
          <div class="pay-opt" onclick="selecionarPag(this,'cartao')">💳 Cartao</div>
        </div>
      </div>
      <div class="form-group">
        <label class="form-label">Observacao (opcional)</label>
        <input class="form-input" id="f-obs" placeholder="Ex: sem cebola, busco no local, entrega as 18h...">
      </div>

      <button class="send-btn" id="send-btn" onclick="enviarPedido()">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="white"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347z"/><path d="M12 0C5.373 0 0 5.373 0 12c0 2.127.558 4.126 1.534 5.858L0 24l6.334-1.508A11.955 11.955 0 0012 24c6.627 0 12-5.373 12-12S18.627 0 12 0zm0 22c-1.885 0-3.655-.52-5.17-1.426l-.37-.22-3.76.895.944-3.656-.242-.376A9.952 9.952 0 012 12C2 6.477 6.477 2 12 2s10 4.477 10 10-4.477 10-10 10z"/></svg>
        Confirmar e enviar pelo WhatsApp
      </button>
    </div>

    <!-- TELA SUCESSO -->
    <div class="success-screen" id="tela-sucesso">
      <div class="big">🎉</div>
      <h2>Pedido enviado!</h2>
      <p>Obrigada pela preferencia!<br>A Gica vai confirmar em breve pelo WhatsApp.</p>
      <button class="novo-btn" onclick="resetar()">Fazer novo pedido</button>
    </div>

  </div>
</div>

<script>
const SUPABASE_URL = 'https://ibtomzrzxettpizbpait.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlidG9tenJ6eGV0dHBpemJwYWl0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzNTAyNTksImV4cCI6MjA5NTkyNjI1OX0.O_avjNNDxw9_qlsR4wtdpOyHINsc8hJy82wlT0KgtCA';
const sb = supabase.createClient(SUPABASE_URL, SUPABASE_KEY);

// << TROQUE PELO NUMERO DA GICA: 55 + DDD + NUMERO, sem espacos ou simbolos
const WHATSAPP = '5511999999999';

const PRODUTOS = [
  {id:1, cat:'Salgados Calabresa', emoji:'🍞', nome:'Salgados Calabresa I',   preco:25, desc:'Porcao pequena'},
  {id:2, cat:'Salgados Calabresa', emoji:'🍞', nome:'Salgados Calabresa II',  preco:26, desc:'Porcao media'},
  {id:3, cat:'Salgados Calabresa', emoji:'🍞', nome:'Salgados Calabresa III', preco:28, desc:'Porcao grande'},
  {id:4, cat:'Salgados Frango',    emoji:'🍗', nome:'Salgados Frango I',      preco:25, desc:'Porcao pequena'},
  {id:5, cat:'Salgados Frango',    emoji:'🍗', nome:'Salgados Frango II',     preco:26, desc:'Porcao media'},
  {id:6, cat:'Salgados Frango',    emoji:'🍗', nome:'Salgados Frango III',    preco:28, desc:'Porcao grande'},
  {id:7, cat:'Especiais',          emoji:'🥖', nome:'Bauru',                  preco:28, desc:'Classico e saboroso'},
  {id:8, cat:'Especiais',          emoji:'🥖', nome:'Portuguesa',             preco:28, desc:'Ingredientes especiais'},
  {id:9, cat:'Especiais',          emoji:'🥖', nome:'Frios',                  preco:28, desc:'Sortido de frios'},
  {id:10,cat:'Lanches',            emoji:'🥪', nome:'Lanche Frango',          preco:15, desc:'Lanche artesanal'},
  {id:11,cat:'Lanches',            emoji:'🥪', nome:'Lanche Frios',           preco:15, desc:'Lanche artesanal'},
  {id:12,cat:'Bolos',              emoji:'🎂', nome:'Bolo Limao',             preco:30, desc:'Fofinho e citrico'},
  {id:13,cat:'Bolos',              emoji:'🎂', nome:'Bolo Morango',           preco:30, desc:'Com recheio especial'},
  {id:14,cat:'Bolos',              emoji:'🎂', nome:'Bolo Laranja',           preco:30, desc:'Aroma inconfundivel'},
  {id:15,cat:'Bolos',              emoji:'🎂', nome:'Bolo Uva',               preco:30, desc:'Sabor unico'},
  {id:16,cat:'Bolos',              emoji:'🎂', nome:'Bolo Maracuja',          preco:30, desc:'Tropical e delicioso'},
  {id:17,cat:'Bolos',              emoji:'🎂', nome:'Bolo Chocolate',         preco:30, desc:'O favorito de todos'},
  {id:18,cat:'Bolos',              emoji:'🎂', nome:'Bolo Coco',              preco:30, desc:'Artesanal e especial'},
];

let cart = {};
let pagamento = 'pix';
let catAtiva = 'Todas';

const cats = ['Todas', ...new Set(PRODUTOS.map(p => p.cat))];

// Setar data de hoje como padrao
window.onload = () => {
  const hoje = new Date().toISOString().slice(0,10);
  document.getElementById('f-data-pedido').value = hoje;
  initCategorias();
  renderProdutos();
};

function initCategorias() {
  document.getElementById('categories').innerHTML = cats.map(c =>
    `<button class="cat-btn ${c===catAtiva?'active':''}" onclick="filtrarCat('${c}',this)">${c==='Todas'?'Todas':PRODUTOS.find(p=>p.cat===c).emoji+' '+c}</button>`
  ).join('');
}

function filtrarCat(cat, el) {
  catAtiva = cat;
  document.querySelectorAll('.cat-btn').forEach(b => b.classList.remove('active'));
  el.classList.add('active');
  renderProdutos();
}

function renderProdutos() {
  const s = document.getElementById('search').value.toLowerCase();
  const filtrados = PRODUTOS.filter(p =>
    (catAtiva === 'Todas' || p.cat === catAtiva) &&
    (!s || p.nome.toLowerCase().includes(s))
  );
  const agrupados = {};
  filtrados.forEach(p => { if (!agrupados[p.cat]) agrupados[p.cat] = []; agrupados[p.cat].push(p); });

  document.getElementById('products-list').innerHTML = Object.entries(agrupados).map(([cat, itens]) => `
    <div class="category-title">${itens[0].emoji} ${cat}</div>
    ${itens.map(p => `
      <div class="product-card">
        <div class="product-info">
          <div class="product-name">${p.nome}</div>
          <div class="product-desc">${p.desc}</div>
          <div class="product-price">R$ ${p.preco.toFixed(2).replace('.',',')}</div>
        </div>
        <div class="qty-control">
          <button class="qty-btn minus" onclick="mudarQty(${p.id},-1)">-</button>
          <span class="qty-num" id="qty-${p.id}">${cart[p.id]||0}</span>
          <button class="qty-btn plus" onclick="mudarQty(${p.id},1)">+</button>
        </div>
      </div>`).join('')}
  `).join('');
}

function mudarQty(id, delta) {
  cart[id] = Math.max(0, (cart[id]||0) + delta);
  const el = document.getElementById('qty-'+id);
  if (el) el.textContent = cart[id];
  atualizarBarra();
}

function totalItens() { return Object.values(cart).reduce((s,v) => s+v, 0); }
function calcTotal()  { return PRODUTOS.reduce((s,p) => s + p.preco*(cart[p.id]||0), 0); }
function fmt(v)       { return 'R$ ' + v.toFixed(2).replace('.',','); }

function atualizarBarra() {
  const t = totalItens();
  document.getElementById('cart-bar').classList.toggle('visible', t > 0);
  document.getElementById('cart-count').textContent = t;
  document.getElementById('cart-total-bar').textContent = fmt(calcTotal());
}

function abrirModal() {
  const itens = PRODUTOS.filter(p => cart[p.id] > 0);
  document.getElementById('cart-items-list').innerHTML = itens.length
    ? itens.map(p => `
        <div class="cart-item">
          <div>
            <div class="cart-item-name">${p.nome}</div>
            <div class="cart-item-detail">${cart[p.id]}x × ${fmt(p.preco)}</div>
          </div>
          <span class="cart-item-price">${fmt(p.preco*cart[p.id])}</span>
        </div>`).join('')
    : '<div class="empty-state">Nenhum item</div>';
  document.getElementById('cart-total-modal').textContent = fmt(calcTotal());
  document.getElementById('modal').classList.add('open');
}

function fecharModal() { document.getElementById('modal').classList.remove('open'); }

function selecionarPag(el, metodo) {
  pagamento = metodo;
  document.querySelectorAll('.pay-opt').forEach(b => b.classList.remove('selected'));
  el.classList.add('selected');
}

async function enviarPedido() {
  const nome        = document.getElementById('f-nome').value.trim();
  const tel         = document.getElementById('f-tel').value.trim();
  const dataPedido  = document.getElementById('f-data-pedido').value;
  const dataEntrega = document.getElementById('f-data-entrega').value;
  const obs         = document.getElementById('f-obs').value.trim();

  if (!nome) { alert('Por favor informe seu nome!'); return; }
  if (!tel)  { alert('Por favor informe seu WhatsApp!'); return; }

  const itens = PRODUTOS.filter(p => cart[p.id] > 0).map(p => ({nome:p.nome, qty:cart[p.id], preco:p.preco}));
  if (!itens.length) { alert('Adicione pelo menos um item!'); return; }

  const btn = document.getElementById('send-btn');
  btn.disabled = true;
  btn.textContent = 'Enviando...';

  // Salvar no Supabase
  try {
    await sb.from('pedidos').insert({
      cliente:       nome,
      telefone:      tel,
      items:         itens,
      total:         calcTotal(),
      status:        'pendente',
      pagamento:     pagamento,
      data_pedido:   dataPedido,
      data_entrega:  dataEntrega || null,
      obs:           obs,
    });
  } catch(e) { console.error('Supabase erro:', e); }

  // Montar mensagem WhatsApp
  const linhasItens = itens.map(i => `  - ${i.qty}x ${i.nome} = ${fmt(i.preco*i.qty)}`).join('\n');
  const fmtData = d => { if(!d)return''; const[y,m,dia]=d.split('-'); return`${dia}/${m}/${y}`; };
  const msg = [
    '🎂 *NOVO PEDIDO - GICA Sabores*',
    '',
    `👤 *Cliente:* ${nome}`,
    `📱 *WhatsApp:* ${tel}`,
    '',
    '*Itens pedidos:*',
    linhasItens,
    '',
    `💰 *Total: ${fmt(calcTotal())}*`,
    `💳 *Pagamento:* ${pagamento.toUpperCase()}`,
    `📅 *Data do pedido:* ${fmtData(dataPedido)}`,
    dataEntrega ? `🚚 *Entrega para:* ${fmtData(dataEntrega)}` : '',
    obs ? `📝 *Obs:* ${obs}` : '',
  ].filter(l => l !== '').join('\n');

  window.open('https://wa.me/' + WHATSAPP + '?text=' + encodeURIComponent(msg), '_blank');

  document.getElementById('tela-pedido').style.display = 'none';
  document.getElementById('tela-sucesso').style.display = 'block';
}

function resetar() {
  cart = {};
  ['f-nome','f-tel','f-obs','f-data-entrega'].forEach(id => document.getElementById(id).value = '');
  document.getElementById('f-data-pedido').value = new Date().toISOString().slice(0,10);
  document.getElementById('send-btn').disabled = false;
  document.getElementById('send-btn').innerHTML = 'Confirmar e enviar pelo WhatsApp';
  document.getElementById('tela-pedido').style.display = '';
  document.getElementById('tela-sucesso').style.display = 'none';
  fecharModal();
  atualizarBarra();
  renderProdutos();
}
</script>
</body>
</html>
'@
$cardapio | Out-File -FilePath "Cardapio GICA.html" -Encoding UTF8
Write-Host "[OK] Cardapio GICA.html criado" -ForegroundColor Green

# ── 3. Painel GICA.html ────────────────────
$painel = @'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>GICA Sabores - Painel</title>
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<style>
@import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Lato:wght@300;400;700&display=swap');
:root{--gold:#C9A84C;--gold-light:#F5E6C0;--gold-dark:#8B6914;--brown:#5C3D1E;--cream:#FDF8F0;--dark:#2C1810;}
*{box-sizing:border-box;margin:0;padding:0;}
body{font-family:'Lato',sans-serif;background:#F4F1EC;color:var(--dark);min-height:100vh;}
.header{background:linear-gradient(135deg,var(--brown),var(--dark));padding:1rem 1.5rem;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px;}
.logo{display:flex;align-items:center;gap:12px;}
.logo-icon{width:44px;height:44px;border-radius:50%;background:linear-gradient(135deg,var(--gold),var(--gold-dark));display:flex;align-items:center;justify-content:center;font-size:22px;}
.logo-text{color:var(--gold);font-family:'Playfair Display',serif;font-size:1.2rem;}
.logo-sub{color:rgba(255,255,255,0.6);font-size:11px;margin-top:1px;}
.dot{width:7px;height:7px;border-radius:50%;background:#27ae60;display:inline-block;margin-right:4px;animation:pulse 1.5s infinite;}
@keyframes pulse{0%,100%{opacity:1}50%{opacity:.4}}
.hbtns{display:flex;gap:8px;flex-wrap:wrap;}
.hbtn{padding:8px 16px;border-radius:20px;border:1px solid rgba(255,255,255,0.3);background:rgba(255,255,255,0.1);color:white;font-size:13px;cursor:pointer;font-family:'Lato',sans-serif;transition:all .2s;}
.hbtn:hover{background:rgba(255,255,255,0.2);}
.hbtn-gold{background:var(--gold);border-color:var(--gold);color:var(--dark);font-weight:700;}
.hbtn-gold:hover{background:var(--gold-dark);color:white;}
.wrap{max-width:920px;margin:0 auto;padding:1.5rem 1rem;}
.tabs{display:flex;gap:4px;background:white;border-radius:12px;padding:4px;margin-bottom:1.5rem;box-shadow:0 2px 8px rgba(0,0,0,.06);}
.tab{flex:1;padding:10px;text-align:center;border:none;border-radius:8px;background:none;cursor:pointer;font-size:13px;color:#888;font-family:'Lato',sans-serif;font-weight:700;transition:all .2s;}
.tab.active{background:var(--gold);color:white;}
.metrics{display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:12px;margin-bottom:1.5rem;}
.metric{background:white;border-radius:12px;padding:1rem;box-shadow:0 2px 8px rgba(0,0,0,.06);}
.metric-label{font-size:11px;color:#888;text-transform:uppercase;letter-spacing:.5px;margin-bottom:4px;}
.metric-value{font-size:21px;font-weight:700;color:var(--dark);}
.metric-sub{font-size:11px;color:#aaa;margin-top:2px;}
.metric.ok .metric-value{color:#1a7a4a;}
.metric.ruim .metric-value{color:#c0392b;}
.frow{display:flex;align-items:center;justify-content:space-between;gap:10px;margin-bottom:1rem;flex-wrap:wrap;}
.filtros{display:flex;gap:6px;flex-wrap:wrap;}
.fbtn{padding:6px 14px;border-radius:20px;border:1px solid #ddd;background:white;color:#666;font-size:12px;cursor:pointer;font-family:'Lato',sans-serif;font-weight:700;transition:all .15s;}
.fbtn.active{background:var(--gold);border-color:var(--gold);color:white;}
.busca{padding:8px 14px;border:1px solid #ddd;border-radius:20px;font-size:13px;outline:none;background:white;width:180px;}
.busca:focus{border-color:var(--gold);}
.lista{display:flex;flex-direction:column;gap:10px;}
.card{background:white;border-radius:12px;padding:14px 16px;cursor:pointer;box-shadow:0 2px 8px rgba(0,0,0,.06);border-left:4px solid transparent;transition:all .2s;}
.card:hover{box-shadow:0 4px 16px rgba(0,0,0,.1);}
.card.pago{border-left-color:#27ae60;}
.card.pendente{border-left-color:#f39c12;}
.card.atrasado{border-left-color:#e74c3c;}
.card.reagendado{border-left-color:#3498db;}
.ctop{display:flex;align-items:center;justify-content:space-between;margin-bottom:6px;}
.cnome{display:flex;align-items:center;gap:10px;font-weight:700;font-size:14px;}
.av{width:34px;height:34px;border-radius:50%;background:var(--gold-light);display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:700;color:var(--gold-dark);flex-shrink:0;}
.cright{display:flex;align-items:center;gap:8px;}
.ctotal{font-weight:700;font-size:15px;}
.badge{padding:3px 10px;border-radius:20px;font-size:11px;font-weight:700;}
.b-pago{background:#d5f5e3;color:#1a7a4a;}
.b-pendente{background:#fef9e7;color:#b7770d;}
.b-atrasado{background:#fde8e8;color:#c0392b;}
.b-reagendado{background:#ebf5fb;color:#1a5276;}
.citens{font-size:12px;color:#888;margin-bottom:6px;}
.cmeta{display:flex;gap:8px;font-size:11px;flex-wrap:wrap;}
.pill{background:#f5f5f5;padding:2px 8px;border-radius:10px;color:#666;}
.new-badge{background:var(--gold);color:white;padding:2px 8px;border-radius:10px;font-size:10px;font-weight:700;animation:pulse 2s infinite;}
.rgrid{display:grid;grid-template-columns:1fr 1fr;gap:12px;}
@media(max-width:500px){.rgrid{grid-template-columns:1fr;}}
.rcard{background:white;border-radius:12px;padding:1rem 1.25rem;box-shadow:0 2px 8px rgba(0,0,0,.06);}
.rcard h3{font-size:12px;color:#888;margin-bottom:14px;text-transform:uppercase;letter-spacing:.5px;}
.mbar{display:flex;align-items:center;gap:8px;margin-bottom:10px;}
.mname{font-size:12px;color:#888;width:36px;}
.mtrack{flex:1;height:8px;background:#f0f0f0;border-radius:4px;overflow:hidden;}
.mfill{height:100%;border-radius:4px;background:linear-gradient(90deg,var(--gold-light),var(--gold));}
.mval{font-size:12px;font-weight:700;color:var(--dark);width:75px;text-align:right;}
.drow{display:flex;justify-content:space-between;align-items:center;padding:8px 0;border-bottom:1px solid #f5f5f5;font-size:13px;}
.drow:last-child{border-bottom:none;}
.prow{display:flex;justify-content:space-between;padding:8px 0;font-size:13px;}
.prow:not(:last-child){border-bottom:1px solid #f5f5f5;}
.modal{display:none;position:fixed;inset:0;z-index:100;}
.modal.open{display:flex;}
.modal-bg{position:absolute;inset:0;background:rgba(0,0,0,.4);}
.mbox{position:relative;background:var(--cream);width:100%;max-width:500px;margin:auto;border-radius:16px;max-height:90vh;overflow-y:auto;padding:1.5rem;animation:fi .2s;}
@keyframes fi{from{opacity:0;transform:scale(.97)}to{opacity:1;transform:scale(1)}}
.mtitle{font-family:'Playfair Display',serif;font-size:1.2rem;color:var(--brown);margin-bottom:1rem;}
.fg{margin-bottom:12px;}
.fl{font-size:11px;font-weight:700;color:var(--brown);text-transform:uppercase;letter-spacing:.5px;display:block;margin-bottom:5px;}
.fi,.fs{width:100%;padding:10px 14px;border:1px solid #ddd;border-radius:8px;font-size:14px;background:white;color:var(--dark);outline:none;font-family:'Lato',sans-serif;}
.fi:focus,.fs:focus{border-color:var(--gold);}
.fr{display:grid;grid-template-columns:1fr 1fr;gap:10px;}
.ibox{border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:12px;background:white;}
.irow{display:flex;align-items:center;gap:8px;margin-bottom:8px;}
.irow:last-child{margin-bottom:0;}
.irem{background:none;border:none;color:#e74c3c;cursor:pointer;font-size:17px;padding:0 4px;}
.tline{display:flex;justify-content:space-between;font-weight:700;font-size:16px;padding-top:12px;border-top:2px solid var(--gold-light);color:var(--dark);}
.mfooter{display:flex;gap:8px;justify-content:flex-end;margin-top:1.5rem;padding-top:1rem;border-top:1px solid var(--gold-light);}
.mb{padding:10px 20px;border-radius:20px;border:1px solid #ddd;background:white;color:var(--dark);font-size:14px;cursor:pointer;font-family:'Lato',sans-serif;font-weight:700;transition:all .15s;}
.mb:hover{background:#f5f5f5;}
.mb-gold{background:var(--gold);border-color:var(--gold);color:white;}
.mb-gold:hover{background:var(--gold-dark);}
.mb-del{color:#e74c3c;border-color:#e74c3c;}
.mb-del:hover{background:#fde8e8;}
.loading{text-align:center;padding:2rem;color:#aaa;font-size:14px;}
.empty{text-align:center;padding:2rem;color:#aaa;font-size:14px;}
</style>
</head>
<body>
<div class="header">
  <div class="logo">
    <div class="logo-icon">🎂</div>
    <div>
      <div class="logo-text">GICA Sabores</div>
      <div class="logo-sub"><span class="dot"></span>Painel · Ao vivo</div>
    </div>
  </div>
  <div class="hbtns">
    <button class="hbtn" onclick="exportar()">⬇ Exportar</button>
    <button class="hbtn hbtn-gold" onclick="abrirNovo()">+ Novo pedido</button>
  </div>
</div>

<div class="wrap">
  <div class="tabs">
    <button class="tab active" onclick="mudarTab('pedidos',this)">📋 Pedidos</button>
    <button class="tab" onclick="mudarTab('relatorio',this)">📊 Relatorio</button>
  </div>

  <div id="tab-pedidos">
    <div class="metrics" id="metrics"><div class="loading">Carregando...</div></div>
    <div class="frow">
      <div class="filtros">
        <button class="fbtn active" onclick="setFiltro('todos',this)">Todos</button>
        <button class="fbtn" onclick="setFiltro('pendente',this)">Pendentes</button>
        <button class="fbtn" onclick="setFiltro('pago',this)">Pagos</button>
        <button class="fbtn" onclick="setFiltro('atrasado',this)">Atrasados</button>
        <button class="fbtn" onclick="setFiltro('reagendado',this)">Reagendados</button>
      </div>
      <input class="busca" id="busca" placeholder="🔍 Buscar..." oninput="renderLista()">
    </div>
    <div class="lista" id="lista"><div class="loading">Carregando...</div></div>
  </div>

  <div id="tab-relatorio" style="display:none">
    <div class="rgrid" id="rgrid"></div>
  </div>
</div>

<div class="modal" id="modal">
  <div class="modal-bg" onclick="fecharModal()"></div>
  <div class="mbox">
    <div class="mtitle" id="mtitle">Novo pedido</div>
    <div id="mbody"></div>
    <div class="mfooter" id="mfooter"></div>
  </div>
</div>

<script>
const SUPABASE_URL = 'https://ibtomzrzxettpizbpait.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlidG9tenJ6eGV0dHBpemJwYWl0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzNTAyNTksImV4cCI6MjA5NTkyNjI1OX0.O_avjNNDxw9_qlsR4wtdpOyHINsc8hJy82wlT0KgtCA';
const sb = supabase.createClient(SUPABASE_URL, SUPABASE_KEY);

const CARDAPIO = [
  {nome:'Salgados Calabresa I',preco:25},{nome:'Salgados Calabresa II',preco:26},{nome:'Salgados Calabresa III',preco:28},
  {nome:'Salgados Frango I',preco:25},{nome:'Salgados Frango II',preco:26},{nome:'Salgados Frango III',preco:28},
  {nome:'Bauru',preco:28},{nome:'Portuguesa',preco:28},{nome:'Frios',preco:28},
  {nome:'Lanche Frango',preco:15},{nome:'Lanche Frios',preco:15},
  {nome:'Bolo Limao',preco:30},{nome:'Bolo Morango',preco:30},{nome:'Bolo Laranja',preco:30},
  {nome:'Bolo Uva',preco:30},{nome:'Bolo Maracuja',preco:30},{nome:'Bolo Chocolate',preco:30},{nome:'Bolo Coco',preco:30},
];

let pedidos=[], filtro='todos', editando=null, tmpItens=[], novo=false, vistos=new Set();

async function carregar() {
  const {data} = await sb.from('pedidos').select('*').order('created_at',{ascending:false});
  pedidos = data || [];
  renderTudo();
}

function renderTudo() { renderMetrics(); renderLista(); }
function fmt(v)       { return 'R$ '+Number(v).toFixed(2).replace('.',','); }
function fmtD(d)      { if(!d)return''; const[y,m,dia]=d.split('-'); return`${dia}/${m}/${y}`; }
function iniciais(n)  { return n.split(' ').slice(0,2).map(w=>w[0]).join('').toUpperCase(); }
function bClass(s)    { return {pago:'b-pago',pendente:'b-pendente',atrasado:'b-atrasado',reagendado:'b-reagendado'}[s]||'b-pendente'; }
function bLabel(s)    { return {pago:'✅ Pago',pendente:'⏳ Pendente',atrasado:'🔴 Atrasado',reagendado:'📅 Reagendado'}[s]||s; }

function renderMetrics() {
  const total   = pedidos.reduce((s,o)=>s+Number(o.total),0);
  const pago    = pedidos.filter(o=>o.status==='pago').reduce((s,o)=>s+Number(o.total),0);
  const areceb  = pedidos.filter(o=>o.status!=='pago').reduce((s,o)=>s+Number(o.total),0);
  const atras   = pedidos.filter(o=>o.status==='atrasado').length;
  document.getElementById('metrics').innerHTML = `
    <div class="metric"><div class="metric-label">Total Geral</div><div class="metric-value">${fmt(total)}</div><div class="metric-sub">${pedidos.length} pedidos</div></div>
    <div class="metric ok"><div class="metric-label">Recebido</div><div class="metric-value">${fmt(pago)}</div><div class="metric-sub">${pedidos.filter(o=>o.status==='pago').length} pagos</div></div>
    <div class="metric ruim"><div class="metric-label">A Receber</div><div class="metric-value">${fmt(areceb)}</div><div class="metric-sub">${pedidos.filter(o=>o.status!=='pago').length} abertos</div></div>
    <div class="metric ${atras>0?'ruim':''}"><div class="metric-label">Atrasados</div><div class="metric-value">${atras}</div><div class="metric-sub">clientes</div></div>`;
}

function renderLista() {
  const s = (document.getElementById('busca')||{}).value||'';
  let lista = pedidos.filter(o =>
    (filtro==='todos'||o.status===filtro) &&
    (!s || o.cliente.toLowerCase().includes(s.toLowerCase()))
  );
  const el = document.getElementById('lista');
  if (!lista.length) { el.innerHTML='<div class="empty">Nenhum pedido encontrado</div>'; return; }
  el.innerHTML = lista.map(o => `
    <div class="card ${o.status}" onclick="abrirEdicao('${o.id}')">
      <div class="ctop">
        <div class="cnome">
          <div class="av">${iniciais(o.cliente)}</div>
          ${o.cliente}
          ${!vistos.has(o.id)?'<span class="new-badge">NOVO</span>':''}
        </div>
        <div class="cright">
          <span class="badge ${bClass(o.status)}">${bLabel(o.status)}</span>
          <span class="ctotal">${fmt(o.total)}</span>
        </div>
      </div>
      <div class="citens">${(o.items||[]).map(i=>`${i.qty}x ${i.nome}`).join(' · ')}</div>
      <div class="cmeta">
        <span class="pill">📅 Pedido: ${fmtD(o.data_pedido)}</span>
        ${o.data_entrega?`<span class="pill">🚚 Entrega: ${fmtD(o.data_entrega)}</span>`:''}
        <span class="pill">${o.pagamento==='pix'?'💳':'💵'} ${o.pagamento.toUpperCase()}</span>
        ${o.telefone?`<span class="pill">📱 ${o.telefone}</span>`:''}
        ${o.reagendado_para?`<span class="pill">📆 Reagend. ${fmtD(o.reagendado_para)}</span>`:''}
        ${o.obs?`<span class="pill" title="${o.obs}">📝 obs</span>`:''}
      </div>
    </div>`).join('');
  vistos = new Set(pedidos.map(o=>o.id));
}

function setFiltro(f,el) { filtro=f; document.querySelectorAll('.fbtn').forEach(b=>b.classList.remove('active')); el.classList.add('active'); renderLista(); }

function mudarTab(tab,el) {
  document.querySelectorAll('.tab').forEach(t=>t.classList.remove('active')); el.classList.add('active');
  document.getElementById('tab-pedidos').style.display   = tab==='pedidos'?'':'none';
  document.getElementById('tab-relatorio').style.display = tab==='relatorio'?'':'none';
  if (tab==='relatorio') renderRelatorio();
}

function renderRelatorio() {
  const MESES = ['Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'];
  const porMes = {};
  pedidos.forEach(o => { const m=o.data_pedido.substring(0,7); if(!porMes[m])porMes[m]=0; porMes[m]+=Number(o.total); });
  const keys = Object.keys(porMes).sort().slice(-6);
  const maxV = Math.max(...keys.map(k=>porMes[k]),1);
  const devedores = pedidos.filter(o=>o.status!=='pago').sort((a,b)=>Number(b.total)-Number(a.total));
  const soma = (pg) => pedidos.filter(o=>o.pagamento===pg&&o.status==='pago').reduce((s,o)=>s+Number(o.total),0);
  const pixR=soma('pix'), dinR=soma('dinheiro'), traR=soma('transferencia'), carR=soma('cartao');
  document.getElementById('rgrid').innerHTML = `
    <div class="rcard" style="grid-column:1/-1">
      <h3>Faturamento por mes</h3>
      ${keys.map(k=>{const[y,m]=k.split('-');return`<div class="mbar"><span class="mname">${MESES[parseInt(m)-1]}</span><div class="mtrack"><div class="mfill" style="width:${(porMes[k]/maxV*100).toFixed(1)}%"></div></div><span class="mval">${fmt(porMes[k])}</span></div>`;}).join('')}
      ${!keys.length?'<div class="empty">Sem dados</div>':''}
    </div>
    <div class="rcard">
      <h3>Quem deve (${devedores.length})</h3>
      ${devedores.length===0?'<p style="color:#27ae60;font-size:13px">Todos em dia! 🎉</p>':devedores.map(o=>`
        <div class="drow">
          <div><div style="font-weight:700;font-size:13px">${o.cliente}</div>
          <div style="font-size:11px;color:#aaa">${fmtD(o.data_pedido)} · ${o.status}${o.reagendado_para?' → '+fmtD(o.reagendado_para):''}</div></div>
          <span style="color:#e74c3c;font-weight:700">${fmt(o.total)}</span>
        </div>`).join('')}
    </div>
    <div class="rcard">
      <h3>Formas de pagamento</h3>
      <div class="prow"><span>💳 Pix</span><span style="font-weight:700">${fmt(pixR)}</span></div>
      <div class="prow"><span>💵 Dinheiro</span><span style="font-weight:700">${fmt(dinR)}</span></div>
      <div class="prow"><span>🏦 Transferencia</span><span style="font-weight:700">${fmt(traR)}</span></div>
      <div class="prow"><span>💳 Cartao</span><span style="font-weight:700">${fmt(carR)}</span></div>
      <div class="prow" style="border-top:2px solid var(--gold-light);margin-top:4px;padding-top:8px">
        <span style="font-weight:700">Total recebido</span>
        <span style="font-weight:700;color:#1a7a4a">${fmt(pixR+dinR+traR+carR)}</span>
      </div>
    </div>`;
}

function bodyModal(p) {
  return `
    <div class="fg"><label class="fl">Nome do cliente</label><input class="fi" id="f-cli" placeholder="Nome completo" value="${p?p.cliente:''}"></div>
    <div class="fr">
      <div class="fg"><label class="fl">WhatsApp</label><input class="fi" id="f-tel" placeholder="(11) 99999" value="${p?p.telefone||'':''}"></div>
      <div class="fg"><label class="fl">Data pedido</label><input class="fi" type="date" id="f-dp" value="${p?p.data_pedido:new Date().toISOString().slice(0,10)}"></div>
    </div>
    <div class="fr">
      <div class="fg"><label class="fl">Data entrega</label><input class="fi" type="date" id="f-de" value="${p?p.data_entrega||'':''}"></div>
      <div class="fg"><label class="fl">Status</label>
        <select class="fs" id="f-st" onchange="togReag()">
          <option value="pendente" ${p&&p.status==='pendente'?'selected':''}>Pendente</option>
          <option value="pago"     ${p&&p.status==='pago'?'selected':''}>Pago</option>
          <option value="atrasado" ${p&&p.status==='atrasado'?'selected':''}>Atrasado</option>
          <option value="reagendado" ${p&&p.status==='reagendado'?'selected':''}>Reagendado</option>
        </select>
      </div>
    </div>
    <div class="fr">
      <div class="fg"><label class="fl">Pagamento</label>
        <select class="fs" id="f-pg">
          <option value="pix"          ${p&&p.pagamento==='pix'?'selected':''}>Pix</option>
          <option value="dinheiro"     ${p&&p.pagamento==='dinheiro'?'selected':''}>Dinheiro</option>
          <option value="transferencia"${p&&p.pagamento==='transferencia'?'selected':''}>Transferencia</option>
          <option value="cartao"       ${p&&p.pagamento==='cartao'?'selected':''}>Cartao</option>
        </select>
      </div>
      <div class="fg" id="reag-g" style="display:${p&&p.status==='reagendado'?'':'none'}">
        <label class="fl">Reagendado para</label>
        <input class="fi" type="date" id="f-rg" value="${p?p.reagendado_para||'':''}">
      </div>
    </div>
    <div class="fg"><label class="fl">Itens do pedido</label>
      <div class="ibox">${itensHTML()}<button class="mb" onclick="addItem()" style="width:100%;margin-top:8px">+ Adicionar item</button></div>
      <div class="tline"><span>Total</span><span id="itotal">${fmt(calcT())}</span></div>
    </div>
    <div class="fg"><label class="fl">Observacao</label><input class="fi" id="f-obs" placeholder="Ex: vai pagar na sexta..." value="${p?p.obs||'':''}"></div>`;
}

function itensHTML() { return tmpItens.map((it,i)=>`<div class="irow"><input class="fi" type="number" min="1" value="${it.qty}" onchange="uQty(${i},this.value)" style="width:58px"><select class="fs" onchange="uNome(${i},this.value)" style="flex:1">${CARDAPIO.map(c=>`<option value="${c.nome}|${c.preco}" ${c.nome===it.nome?'selected':''}>${c.nome} – R$${c.preco}</option>`).join('')}</select><button class="irem" onclick="remItem(${i})">✕</button></div>`).join(''); }
function calcT()     { return tmpItens.reduce((s,i)=>s+(i.preco*i.qty),0); }
function uQty(i,v)   { tmpItens[i].qty=parseInt(v)||1; const el=document.getElementById('itotal'); if(el)el.textContent=fmt(calcT()); }
function uNome(i,v)  { const[n,p]=v.split('|'); tmpItens[i].nome=n; tmpItens[i].preco=parseFloat(p); const el=document.getElementById('itotal'); if(el)el.textContent=fmt(calcT()); }
function remItem(i)  { tmpItens.splice(i,1); document.getElementById('mbody').innerHTML=bodyModal(editando); }
function addItem()   { tmpItens.push({nome:CARDAPIO[0].nome,qty:1,preco:CARDAPIO[0].preco}); document.getElementById('mbody').innerHTML=bodyModal(editando); }
function togReag()   { const v=document.getElementById('f-st').value; document.getElementById('reag-g').style.display=v==='reagendado'?'':'none'; }

function abrirNovo() {
  editando=null; novo=true; tmpItens=[{nome:CARDAPIO[0].nome,qty:1,preco:CARDAPIO[0].preco}];
  document.getElementById('mtitle').textContent='Novo pedido';
  document.getElementById('mbody').innerHTML=bodyModal(null);
  document.getElementById('mfooter').innerHTML='<button class="mb" onclick="fecharModal()">Cancelar</button><button class="mb mb-gold" onclick="salvar()">Salvar</button>';
  document.getElementById('modal').classList.add('open');
}

function abrirEdicao(id) {
  editando=pedidos.find(o=>o.id===id); if(!editando)return;
  novo=false; tmpItens=(editando.items||[]).map(i=>({...i}));
  document.getElementById('mtitle').textContent='Editar pedido';
  document.getElementById('mbody').innerHTML=bodyModal(editando);
  document.getElementById('mfooter').innerHTML=`<button class="mb mb-del" onclick="excluir('${id}')">Excluir</button><div style="flex:1"></div><button class="mb" onclick="fecharModal()">Cancelar</button><button class="mb mb-gold" onclick="salvar()">Salvar</button>`;
  document.getElementById('modal').classList.add('open');
}

async function salvar() {
  const cli = document.getElementById('f-cli').value.trim();
  if (!cli) { alert('Informe o nome do cliente'); return; }
  if (!tmpItens.length) { alert('Adicione pelo menos um item'); return; }
  const st = document.getElementById('f-st').value;
  const payload = {
    cliente:        cli,
    telefone:       document.getElementById('f-tel').value,
    items:          tmpItens,
    total:          calcT(),
    status:         st,
    pagamento:      document.getElementById('f-pg').value,
    data_pedido:    document.getElementById('f-dp').value,
    data_entrega:   document.getElementById('f-de').value || null,
    obs:            document.getElementById('f-obs').value,
    reagendado_para: st==='reagendado'?(document.getElementById('f-rg').value||null):null,
  };
  if (novo) { await sb.from('pedidos').insert(payload); }
  else      { await sb.from('pedidos').update(payload).eq('id',editando.id); }
  fecharModal(); await carregar();
}

async function excluir(id) {
  if (!confirm('Excluir este pedido?')) return;
  await sb.from('pedidos').delete().eq('id',id);
  fecharModal(); await carregar();
}

function fecharModal() { document.getElementById('modal').classList.remove('open'); }

function exportar() {
  const csv = ['Cliente,Tel,Itens,Total,Status,Pagamento,Data Pedido,Data Entrega,Obs',
    ...pedidos.map(o=>`"${o.cliente}","${o.telefone||''}","${(o.items||[]).map(i=>i.qty+'x '+i.nome).join('; ')}","${fmt(o.total)}","${o.status}","${o.pagamento}","${fmtD(o.data_pedido)}","${fmtD(o.data_entrega)}","${o.obs||''}"`)
  ].join('\n');
  const a=document.createElement('a');
  a.href=URL.createObjectURL(new Blob(['\uFEFF'+csv],{type:'text/csv;charset=utf-8'}));
  a.download='gica-pedidos.csv'; a.click();
}

// Tempo real: atualiza ao vivo quando chega pedido novo do cardapio
sb.channel('pedidos-realtime')
  .on('postgres_changes',{event:'INSERT',schema:'public',table:'pedidos'}, () => carregar())
  .subscribe();

carregar();
</script>
</body>
</html>
'@
$painel | Out-File -FilePath "Painel GICA.html" -Encoding UTF8
Write-Host "[OK] Painel GICA.html criado" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  PRONTO! 3 arquivos gerados:" -ForegroundColor Green
Write-Host "  setup_supabase.sql" -ForegroundColor White
Write-Host "  Cardapio GICA.html" -ForegroundColor White
Write-Host "  Painel GICA.html" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "PROXIMO PASSO:" -ForegroundColor Yellow
Write-Host "1. Supabase > SQL Editor > cole o setup_supabase.sql > Run" -ForegroundColor White
Write-Host "2. No Cardapio GICA.html troque o numero:" -ForegroundColor White
Write-Host "   const WHATSAPP = '5511999999999';" -ForegroundColor Cyan
Write-Host "3. git add . && git commit -m 'sistema completo' && git push" -ForegroundColor White
Write-Host ""
