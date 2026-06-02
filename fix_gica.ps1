# Cole e rode no terminal do VS Code
$c = @'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>GICA Sabores - Card&#225;pio</title>
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;600;700&family=Lato:wght@300;400;700&display=swap');
  :root {
    --gold: #C9A84C; --gold-light: #F5E6C0; --gold-dark: #8B6914;
    --brown: #5C3D1E; --cream: #FDF8F0; --dark: #2C1810;
  }
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: 'Lato', sans-serif; background: var(--cream); color: var(--dark); }

  /* HEADER */
  .header { background: linear-gradient(135deg, var(--brown) 0%, var(--dark) 100%); padding: 2rem 1rem 1.5rem; text-align: center; position: relative; overflow: hidden; }
  .header::before { content: ''; position: absolute; inset: 0; background: url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23C9A84C' fill-opacity='0.08'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E"); }
  .header-content { position: relative; }
  .logo-circle { width: 80px; height: 80px; border-radius: 50%; background: linear-gradient(135deg, var(--gold), var(--gold-dark)); margin: 0 auto 1rem; display: flex; align-items: center; justify-content: center; font-size: 36px; box-shadow: 0 4px 20px rgba(201,168,76,0.4); }
  .header h1 { font-family: 'Playfair Display', serif; color: var(--gold); font-size: 2rem; letter-spacing: 2px; }
  .header p { color: rgba(255,255,255,0.7); font-size: 0.85rem; margin-top: 4px; letter-spacing: 1px; text-transform: uppercase; }

  /* SEARCH */
  .search-bar { padding: 1rem; background: white; border-bottom: 1px solid var(--gold-light); }
  .search-bar input { width: 100%; padding: 10px 16px; border: 1px solid var(--gold-light); border-radius: 25px; font-size: 14px; outline: none; background: var(--cream); color: var(--dark); }
  .search-bar input:focus { border-color: var(--gold); }

  /* CATEGORIES */
  .categories { display: flex; gap: 8px; padding: 1rem; overflow-x: auto; background: white; border-bottom: 1px solid var(--gold-light); scrollbar-width: none; }
  .categories::-webkit-scrollbar { display: none; }
  .cat-btn { padding: 6px 16px; border-radius: 20px; border: 1px solid var(--gold-light); background: white; color: var(--brown); font-size: 13px; cursor: pointer; white-space: nowrap; transition: all 0.2s; font-family: 'Lato', sans-serif; }
  .cat-btn.active { background: var(--gold); border-color: var(--gold); color: white; }

  /* PRODUCTS */
  .products { padding: 1rem; max-width: 600px; margin: 0 auto; }
  .category-title { font-family: 'Playfair Display', serif; font-size: 1.2rem; color: var(--brown); margin: 1.5rem 0 0.75rem; padding-bottom: 6px; border-bottom: 2px solid var(--gold-light); display: flex; align-items: center; gap: 8px; }
  .product-card { background: white; border-radius: 12px; padding: 14px; margin-bottom: 10px; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 2px 8px rgba(0,0,0,0.06); border: 1px solid transparent; transition: all 0.2s; }
  .product-card:hover { border-color: var(--gold-light); box-shadow: 0 4px 16px rgba(0,0,0,0.1); }
  .product-info { flex: 1; }
  .product-name { font-weight: 700; font-size: 14px; color: var(--dark); }
  .product-desc { font-size: 12px; color: #888; margin-top: 2px; }
  .product-price { font-weight: 700; color: var(--gold-dark); font-size: 15px; margin-top: 4px; }
  .product-right { display: flex; align-items: center; gap: 10px; flex-shrink: 0; }
  .qty-control { display: flex; align-items: center; gap: 8px; }
  .qty-btn { width: 28px; height: 28px; border-radius: 50%; border: none; cursor: pointer; font-size: 16px; display: flex; align-items: center; justify-content: center; transition: all 0.15s; font-weight: 700; }
  .qty-btn.minus { background: var(--gold-light); color: var(--gold-dark); }
  .qty-btn.plus { background: var(--gold); color: white; }
  .qty-btn:hover { transform: scale(1.1); }
  .qty-num { font-weight: 700; font-size: 15px; min-width: 20px; text-align: center; color: var(--dark); }

  /* CART */
  .cart-bar { position: fixed; bottom: 0; left: 0; right: 0; padding: 1rem; background: white; border-top: 2px solid var(--gold-light); transform: translateY(100%); transition: transform 0.3s; z-index: 50; box-shadow: 0 -4px 20px rgba(0,0,0,0.1); }
  .cart-bar.visible { transform: translateY(0); }
  .cart-btn { width: 100%; max-width: 500px; margin: 0 auto; display: flex; align-items: center; justify-content: space-between; background: linear-gradient(135deg, var(--brown), var(--dark)); color: white; border: none; border-radius: 25px; padding: 14px 20px; cursor: pointer; font-family: 'Lato', sans-serif; font-size: 15px; font-weight: 700; transition: transform 0.15s; }
  .cart-btn:hover { transform: scale(1.02); }
  .cart-count { background: var(--gold); color: white; width: 24px; height: 24px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 12px; }

  /* MODAL PEDIDO */
  .modal { display: none; position: fixed; inset: 0; z-index: 100; }
  .modal.open { display: flex; }
  .modal-bg { position: absolute; inset: 0; background: rgba(0,0,0,0.5); }
  .modal-box { position: relative; background: var(--cream); width: 100%; max-width: 500px; margin: auto; border-radius: 20px 20px 0 0; max-height: 90vh; overflow-y: auto; padding: 1.5rem; animation: slideUp 0.3s ease; }
  @keyframes slideUp { from { transform: translateY(100%); } to { transform: translateY(0); } }
  .modal-title { font-family: 'Playfair Display', serif; font-size: 1.3rem; color: var(--brown); margin-bottom: 1rem; }
  .cart-items { margin-bottom: 1rem; }
  .cart-item { display: flex; justify-content: space-between; align-items: center; padding: 10px 0; border-bottom: 1px solid var(--gold-light); font-size: 14px; }
  .cart-item-name { color: var(--dark); font-weight: 600; }
  .cart-item-detail { color: #888; font-size: 12px; }
  .cart-item-price { font-weight: 700; color: var(--gold-dark); }
  .cart-total { display: flex; justify-content: space-between; font-size: 18px; font-weight: 700; padding: 12px 0; color: var(--dark); border-top: 2px solid var(--gold); margin-bottom: 1.5rem; }
  .form-group { margin-bottom: 14px; }
  .form-label { font-size: 12px; font-weight: 700; color: var(--brown); text-transform: uppercase; letter-spacing: 0.5px; display: block; margin-bottom: 6px; }
  .form-input { width: 100%; padding: 12px 16px; border: 1px solid var(--gold-light); border-radius: 10px; font-size: 14px; background: white; color: var(--dark); outline: none; font-family: 'Lato', sans-serif; }
  .form-input:focus { border-color: var(--gold); }
  .payment-options { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
  .pay-opt { padding: 10px; border: 2px solid var(--gold-light); border-radius: 10px; text-align: center; cursor: pointer; transition: all 0.2s; font-size: 13px; font-weight: 600; color: var(--brown); background: white; }
  .pay-opt.selected { border-color: var(--gold); background: var(--gold-light); }
  .send-btn { width: 100%; padding: 16px; background: linear-gradient(135deg, #25D366, #128C7E); color: white; border: none; border-radius: 25px; font-size: 16px; font-weight: 700; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 10px; font-family: 'Lato', sans-serif; margin-top: 1rem; transition: transform 0.15s; }
  .send-btn:hover { transform: scale(1.02); }
  .send-btn:disabled { opacity: 0.6; cursor: not-allowed; transform: none; }
  .success-msg { display: none; text-align: center; padding: 2rem; }
  .success-msg .emoji { font-size: 4rem; margin-bottom: 1rem; }
  .success-msg h2 { font-family: 'Playfair Display', serif; color: var(--brown); margin-bottom: 0.5rem; }
  .success-msg p { color: #888; font-size: 14px; }

  .badge-novo { display: inline-block; background: var(--gold); color: white; font-size: 10px; padding: 2px 7px; border-radius: 10px; margin-left: 6px; font-weight: 700; vertical-align: middle; }
  .empty-cart { text-align: center; padding: 1rem; color: #aaa; font-size: 14px; }
</style>
</head>
<body>

<div class="header">
  <div class="header-content">
    <div class="logo-circle">&#127874;</div>
    <h1>GICA Sabores</h1>
    <p>Feito com amor e capricho</p>
  </div>
</div>

<div class="search-bar">
  <input type="text" id="search" placeholder="&#128269;  Buscar produto..." oninput="filterProducts()">
</div>

<div class="categories" id="categories"></div>

<div class="products" id="products-list"></div>

<div style="height:100px"></div>

<div class="cart-bar" id="cart-bar">
  <button class="cart-btn" onclick="openCart()">
    <span>&#128722; Ver pedido</span>
    <div style="display:flex;align-items:center;gap:8px">
      <span id="cart-total-bar">R$ 0,00</span>
      <div class="cart-count" id="cart-count">0</div>
    </div>
  </button>
</div>

<!-- MODAL PEDIDO -->
<div class="modal" id="modal">
  <div class="modal-bg" onclick="closeCart()"></div>
  <div class="modal-box">
    <div id="modal-content">
      <div class="modal-title">&#128722; Seu Pedido</div>
      <div class="cart-items" id="cart-items-list"></div>
      <div class="cart-total"><span>Total</span><span id="cart-total-modal">R$ 0,00</span></div>

      <div class="form-group">
        <label class="form-label">Seu nome</label>
        <input class="form-input" id="f-nome" placeholder="Como voc&#234; se chama?">
      </div>
      <div class="form-group">
        <label class="form-label">WhatsApp</label>
        <input class="form-input" id="f-tel" placeholder="(11) 99999-9999" type="tel">
      </div>
      <div class="form-group">
        <label class="form-label">Pagamento</label>
        <div class="payment-options">
          <div class="pay-opt selected" onclick="selectPay(this,'pix')">&#128179; Pix</div>
          <div class="pay-opt" onclick="selectPay(this,'dinheiro')">&#128181; Dinheiro</div>
          <div class="pay-opt" onclick="selectPay(this,'transferencia')">&#127974; Transfer&#234;ncia</div>
          <div class="pay-opt" onclick="selectPay(this,'cartao')">&#128179; Cart&#227;o</div>
        </div>
      </div>
      <div class="form-group">
        <label class="form-label">Observa&#231;&#227;o (opcional)</label>
        <input class="form-input" id="f-obs" placeholder="Ex: sem cebola, entregar &#224;s 18h...">
      </div>
      <button class="send-btn" id="send-btn" onclick="enviarPedido()">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="white"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347z"/><path d="M12 0C5.373 0 0 5.373 0 12c0 2.127.558 4.126 1.534 5.858L0 24l6.334-1.508A11.955 11.955 0 0012 24c6.627 0 12-5.373 12-12S18.627 0 12 0zm0 22c-1.885 0-3.655-.52-5.17-1.426l-.37-.22-3.76.895.944-3.656-.242-.376A9.952 9.952 0 012 12C2 6.477 6.477 2 12 2s10 4.477 10 10-4.477 10-10 10z"/></svg>
        Enviar pelo WhatsApp
      </button>
    </div>
    <div class="success-msg" id="success-msg">
      <div class="emoji">&#127881;</div>
      <h2>Pedido enviado!</h2>
      <p>Obrigada pelo seu pedido!<br>A Gica vai confirmar em breve.</p>
      <button class="send-btn" onclick="resetTudo()" style="background:linear-gradient(135deg,var(--brown),var(--dark));margin-top:1rem">Fazer novo pedido</button>
    </div>
  </div>
</div>

<script>
const SUPABASE_URL = 'https://ibtomzrzxettpizbpait.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlidG9tenJ6eGV0dHBpemJwYWl0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzNTAyNTksImV4cCI6MjA5NTkyNjI1OX0.O_avjNNDxw9_qlsR4wtdpOyHINsc8hJy82wlT0KgtCA';
const sb = supabase.createClient(SUPABASE_URL, SUPABASE_KEY);

const WHATSAPP = '5511999999999'; // TROQUE pelo n&#250;mero da Gica com c&#243;digo do pa&#237;s

const PRODUTOS = [
  { id:1, cat:'&#127838; Salgados Calabresa', nome:'Salgados Calabresa I', preco:25, desc:'Por&#231;&#227;o pequena' },
  { id:2, cat:'&#127838; Salgados Calabresa', nome:'Salgados Calabresa II', preco:26, desc:'Por&#231;&#227;o m&#233;dia' },
  { id:3, cat:'&#127838; Salgados Calabresa', nome:'Salgados Calabresa III', preco:28, desc:'Por&#231;&#227;o grande' },
  { id:4, cat:'&#127831; Salgados Frango', nome:'Salgados Frango I', preco:25, desc:'Por&#231;&#227;o pequena' },
  { id:5, cat:'&#127831; Salgados Frango', nome:'Salgados Frango II', preco:26, desc:'Por&#231;&#227;o m&#233;dia' },
  { id:6, cat:'&#127831; Salgados Frango', nome:'Salgados Frango III', preco:28, desc:'Por&#231;&#227;o grande' },
  { id:7, cat:'&#129366; Especiais', nome:'Bauru', preco:28, desc:'Cl&#225;ssico e saboroso' },
  { id:8, cat:'&#129366; Especiais', nome:'Portuguesa', preco:28, desc:'Com ingredientes especiais' },
  { id:9, cat:'&#129366; Especiais', nome:'Frios', preco:28, desc:'Sortido de frios' },
  { id:10, cat:'&#129386; Lanches', nome:'Lanche Frango', preco:15, desc:'Lanche artesanal' },
  { id:11, cat:'&#129386; Lanches', nome:'Lanche Frios', preco:15, desc:'Lanche artesanal' },
  { id:12, cat:'&#127874; Bolos', nome:'Bolo Lim&#227;o', preco:30, desc:'Fofinho e c&#237;trico' },
  { id:13, cat:'&#127874; Bolos', nome:'Bolo Morango', preco:30, desc:'Com recheio especial' },
  { id:14, cat:'&#127874; Bolos', nome:'Bolo Laranja', preco:30, desc:'Aroma inconfund&#237;vel' },
  { id:15, cat:'&#127874; Bolos', nome:'Bolo Uva', preco:30, desc:'Sabor &#250;nico' },
  { id:16, cat:'&#127874; Bolos', nome:'Bolo Maracuj&#225;', preco:30, desc:'Tropical e delicioso' },
  { id:17, cat:'&#127874; Bolos', nome:'Bolo Chocolate', preco:30, desc:'O favorito de todos' },
  { id:18, cat:'&#127874; Bolos', nome:'Bolo C&#244;co', preco:30, desc:'Artesanal e especial' },
];

let cart = {};
let payMethod = 'pix';
let activeCat = 'Todos';

const cats = ['Todos', ...new Set(PRODUTOS.map(p=>p.cat))];

function initCategories() {
  const el = document.getElementById('categories');
  el.innerHTML = cats.map(c=>`<button class="cat-btn ${c===activeCat?'active':''}" onclick="filterCat('${c}',this)">${c}</button>`).join('');
}

function filterCat(cat, el) {
  activeCat = cat;
  document.querySelectorAll('.cat-btn').forEach(b=>b.classList.remove('active'));
  el.classList.add('active');
  renderProducts();
}

function filterProducts() { renderProducts(); }

function renderProducts() {
  const search = document.getElementById('search').value.toLowerCase();
  const filtered = PRODUTOS.filter(p=>{
    const matchCat = activeCat==='Todos' || p.cat===activeCat;
    const matchSearch = !search || p.nome.toLowerCase().includes(search) || p.cat.toLowerCase().includes(search);
    return matchCat && matchSearch;
  });
  const grouped = {};
  filtered.forEach(p=>{ if(!grouped[p.cat]) grouped[p.cat]=[]; grouped[p.cat].push(p); });
  const el = document.getElementById('products-list');
  el.innerHTML = Object.entries(grouped).map(([cat,items])=>`
    <div class="category-title">${cat}</div>
    ${items.map(p=>`
      <div class="product-card" id="card-${p.id}">
        <div class="product-info">
          <div class="product-name">${p.nome}</div>
          <div class="product-desc">${p.desc}</div>
          <div class="product-price">R$ ${p.preco.toFixed(2).replace('.',',')}</div>
        </div>
        <div class="product-right">
          <div class="qty-control">
            <button class="qty-btn minus" onclick="changeQty(${p.id},-1)">&#8722;</button>
            <span class="qty-num" id="qty-${p.id}">${cart[p.id]||0}</span>
            <button class="qty-btn plus" onclick="changeQty(${p.id},1)">+</button>
          </div>
        </div>
      </div>
    `).join('')}
  `).join('');
}

function changeQty(id, delta) {
  cart[id] = Math.max(0, (cart[id]||0) + delta);
  const el = document.getElementById('qty-'+id);
  if(el) el.textContent = cart[id];
  updateCartBar();
}

function calcTotal() {
  return PRODUTOS.reduce((s,p)=>s+(p.preco*(cart[p.id]||0)),0);
}
function totalItems() {
  return Object.values(cart).reduce((s,v)=>s+v,0);
}
function fmtMoney(v) { return 'R$ '+v.toFixed(2).replace('.',','); }

function updateCartBar() {
  const t = totalItems();
  const bar = document.getElementById('cart-bar');
  bar.classList.toggle('visible', t>0);
  document.getElementById('cart-count').textContent = t;
  document.getElementById('cart-total-bar').textContent = fmtMoney(calcTotal());
}

function openCart() {
  renderCartModal();
  document.getElementById('modal').classList.add('open');
}
function closeCart() { document.getElementById('modal').classList.remove('open'); }

function renderCartModal() {
  const items = PRODUTOS.filter(p=>cart[p.id]>0);
  const el = document.getElementById('cart-items-list');
  if(!items.length) { el.innerHTML='<div class="empty-cart">Nenhum item adicionado</div>'; return; }
  el.innerHTML = items.map(p=>`
    <div class="cart-item">
      <div>
        <div class="cart-item-name">${p.nome}</div>
        <div class="cart-item-detail">${cart[p.id]}x &#215; R$ ${p.preco.toFixed(2).replace('.',',')}</div>
      </div>
      <span class="cart-item-price">${fmtMoney(p.preco*cart[p.id])}</span>
    </div>
  `).join('');
  document.getElementById('cart-total-modal').textContent = fmtMoney(calcTotal());
}

function selectPay(el, method) {
  payMethod = method;
  document.querySelectorAll('.pay-opt').forEach(b=>b.classList.remove('selected'));
  el.classList.add('selected');
}

async function enviarPedido() {
  const nome = document.getElementById('f-nome').value.trim();
  const tel = document.getElementById('f-tel').value.trim();
  const obs = document.getElementById('f-obs').value.trim();
  if(!nome) { alert('Por favor informe seu nome!'); return; }
  const items = PRODUTOS.filter(p=>cart[p.id]>0).map(p=>({nome:p.nome,qty:cart[p.id],preco:p.preco}));
  if(!items.length) { alert('Adicione pelo menos um item!'); return; }

  const btn = document.getElementById('send-btn');
  btn.disabled = true;
  btn.textContent = 'Enviando...';

  // Salvar no Supabase
  try {
    await sb.from('pedidos').insert({
      cliente: nome,
      telefone: tel,
      items: items,
      total: calcTotal(),
      status: 'pendente',
      pagamento: payMethod,
      data_pedido: new Date().toISOString().slice(0,10),
      obs: obs,
    });
  } catch(e) { console.error('Supabase:', e); }

  // Montar mensagem WhatsApp
  const linhas = items.map(i=>`&#8226; ${i.qty}x ${i.nome} &#8212; ${fmtMoney(i.preco*i.qty)}`).join('\n');
  const msg = `&#127874; *NOVO PEDIDO - GICA Sabores*\n\n&#128100; *Cliente:* ${nome}${tel?'\n&#128241; *Tel:* '+tel:''}\n\n*Itens:*\n${linhas}\n\n&#128176; *Total: ${fmtMoney(calcTotal())}*\n&#128179; *Pagamento:* ${payMethod.toUpperCase()}${obs?'\n&#128221; *Obs:* '+obs:''}`;
  const url = `https://wa.me/${WHATSAPP}?text=${encodeURIComponent(msg)}`;
  window.open(url, '_blank');

  document.getElementById('modal-content').style.display = 'none';
  document.getElementById('success-msg').style.display = 'block';
}

function resetTudo() {
  cart = {};
  document.getElementById('f-nome').value = '';
  document.getElementById('f-tel').value = '';
  document.getElementById('f-obs').value = '';
  document.getElementById('modal-content').style.display = '';
  document.getElementById('success-msg').style.display = 'none';
  closeCart();
  updateCartBar();
  renderProducts();
}

initCategories();
renderProducts();
</script>
</body>
</html>

'@
[System.IO.File]::WriteAllText("$PWD\Cardapio GICA.html", $c, [System.Text.Encoding]::UTF8)
Write-Host "[OK] Cardapio GICA.html corrigido" -ForegroundColor Green

$p = @'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>GICA Sabores - Painel Financeiro</title>
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;600;700&family=Lato:wght@300;400;700&display=swap');
  :root { --gold:#C9A84C;--gold-light:#F5E6C0;--gold-dark:#8B6914;--brown:#5C3D1E;--cream:#FDF8F0;--dark:#2C1810; }
  * { box-sizing:border-box;margin:0;padding:0; }
  body { font-family:'Lato',sans-serif;background:#F4F1EC;color:var(--dark);min-height:100vh; }

  .header { background:linear-gradient(135deg,var(--brown),var(--dark));padding:1rem 1.5rem;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px; }
  .logo { display:flex;align-items:center;gap:12px; }
  .logo-icon { width:44px;height:44px;border-radius:50%;background:linear-gradient(135deg,var(--gold),var(--gold-dark));display:flex;align-items:center;justify-content:center;font-size:22px; }
  .logo-text { color:var(--gold);font-family:'Playfair Display',serif;font-size:1.2rem; }
  .logo-sub { color:rgba(255,255,255,0.6);font-size:11px;margin-top:1px; }
  .header-right { display:flex;gap:8px;flex-wrap:wrap; }
  .btn { padding:8px 16px;border-radius:20px;border:1px solid rgba(255,255,255,0.3);background:rgba(255,255,255,0.1);color:white;font-size:13px;cursor:pointer;font-family:'Lato',sans-serif;transition:all 0.2s;display:flex;align-items:center;gap:6px; }
  .btn:hover { background:rgba(255,255,255,0.2); }
  .btn-gold { background:var(--gold);border-color:var(--gold);color:var(--dark);font-weight:700; }
  .btn-gold:hover { background:var(--gold-dark);color:white; }

  .container { max-width:900px;margin:0 auto;padding:1.5rem 1rem; }

  /* TABS */
  .tabs { display:flex;gap:4px;background:white;border-radius:12px;padding:4px;margin-bottom:1.5rem;box-shadow:0 2px 8px rgba(0,0,0,0.06); }
  .tab { flex:1;padding:10px;text-align:center;border:none;border-radius:8px;background:none;cursor:pointer;font-size:13px;color:#888;font-family:'Lato',sans-serif;transition:all 0.2s;font-weight:600; }
  .tab.active { background:var(--gold);color:white; }

  /* METRICS */
  .metrics { display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:12px;margin-bottom:1.5rem; }
  .metric { background:white;border-radius:12px;padding:1rem;box-shadow:0 2px 8px rgba(0,0,0,0.06); }
  .metric-label { font-size:11px;color:#888;text-transform:uppercase;letter-spacing:0.5px;margin-bottom:4px; }
  .metric-value { font-size:22px;font-weight:700;color:var(--dark); }
  .metric-sub { font-size:11px;color:#aaa;margin-top:2px; }
  .metric.success .metric-value { color:#1a7a4a; }
  .metric.danger .metric-value { color:#c0392b; }
  .metric.warn .metric-value { color:var(--gold-dark); }

  /* ORDERS */
  .filters-row { display:flex;align-items:center;justify-content:space-between;gap:10px;margin-bottom:1rem;flex-wrap:wrap; }
  .filters { display:flex;gap:6px;flex-wrap:wrap; }
  .filter-btn { padding:6px 14px;border-radius:20px;border:1px solid #ddd;background:white;color:#666;font-size:12px;cursor:pointer;font-family:'Lato',sans-serif;font-weight:700;transition:all 0.15s; }
  .filter-btn.active { background:var(--gold);border-color:var(--gold);color:white; }
  .search { padding:8px 14px;border:1px solid #ddd;border-radius:20px;font-size:13px;outline:none;background:white;width:180px; }
  .search:focus { border-color:var(--gold); }

  .orders-list { display:flex;flex-direction:column;gap:10px; }
  .order-card { background:white;border-radius:12px;padding:14px 16px;cursor:pointer;box-shadow:0 2px 8px rgba(0,0,0,0.06);border-left:4px solid transparent;transition:all 0.2s; }
  .order-card:hover { box-shadow:0 4px 16px rgba(0,0,0,0.1); }
  .order-card.pago { border-left-color:#27ae60; }
  .order-card.pendente { border-left-color:#f39c12; }
  .order-card.atrasado { border-left-color:#e74c3c; }
  .order-card.reagendado { border-left-color:#3498db; }
  .order-top { display:flex;align-items:center;justify-content:space-between;margin-bottom:6px; }
  .order-client { display:flex;align-items:center;gap:10px;font-weight:700;font-size:14px; }
  .avatar { width:34px;height:34px;border-radius:50%;background:var(--gold-light);display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:700;color:var(--gold-dark);flex-shrink:0; }
  .order-right { display:flex;align-items:center;gap:10px; }
  .order-total { font-weight:700;font-size:15px;color:var(--dark); }
  .badge { padding:3px 10px;border-radius:20px;font-size:11px;font-weight:700; }
  .badge-pago { background:#d5f5e3;color:#1a7a4a; }
  .badge-pendente { background:#fef9e7;color:#b7770d; }
  .badge-atrasado { background:#fde8e8;color:#c0392b; }
  .badge-reagendado { background:#ebf5fb;color:#1a5276; }
  .order-items { font-size:12px;color:#888;margin-bottom:6px; }
  .order-meta { display:flex;gap:10px;font-size:11px;color:#aaa;flex-wrap:wrap; }
  .meta-pill { background:#f5f5f5;padding:2px 8px;border-radius:10px;color:#666; }
  .new-badge { background:var(--gold);color:white;padding:2px 8px;border-radius:10px;font-size:10px;font-weight:700;animation:pulse 2s infinite; }
  @keyframes pulse { 0%,100%{opacity:1} 50%{opacity:0.6} }

  /* REPORT */
  .report-grid { display:grid;grid-template-columns:1fr 1fr;gap:12px; }
  @media(max-width:500px){.report-grid{grid-template-columns:1fr;}}
  .report-card { background:white;border-radius:12px;padding:1rem 1.25rem;box-shadow:0 2px 8px rgba(0,0,0,0.06); }
  .report-card h3 { font-size:13px;color:#888;margin-bottom:14px;text-transform:uppercase;letter-spacing:0.5px; }
  .month-bar { display:flex;align-items:center;gap:8px;margin-bottom:10px; }
  .month-name { font-size:12px;color:#888;width:36px; }
  .bar-track { flex:1;height:8px;background:#f0f0f0;border-radius:4px;overflow:hidden; }
  .bar-fill { height:100%;border-radius:4px;background:linear-gradient(90deg,var(--gold-light),var(--gold));transition:width 0.5s; }
  .month-val { font-size:12px;font-weight:700;color:var(--dark);width:75px;text-align:right; }
  .debtor-row { display:flex;justify-content:space-between;align-items:center;padding:8px 0;border-bottom:1px solid #f5f5f5;font-size:13px; }
  .debtor-row:last-child{border-bottom:none;}
  .pix-row { display:flex;justify-content:space-between;align-items:center;padding:8px 0;font-size:13px; }
  .pix-row:not(:last-child){border-bottom:1px solid #f5f5f5;}

  /* MODAL */
  .modal { display:none;position:fixed;inset:0;z-index:100; }
  .modal.open { display:flex; }
  .modal-bg { position:absolute;inset:0;background:rgba(0,0,0,0.4); }
  .modal-box { position:relative;background:var(--cream);width:100%;max-width:480px;margin:auto;border-radius:16px;max-height:90vh;overflow-y:auto;padding:1.5rem;animation:fadeIn 0.2s; }
  @keyframes fadeIn { from{opacity:0;transform:scale(0.97)} to{opacity:1;transform:scale(1)} }
  .modal-title { font-family:'Playfair Display',serif;font-size:1.2rem;color:var(--brown);margin-bottom:1rem; }
  .form-group { margin-bottom:14px; }
  .form-label { font-size:11px;font-weight:700;color:var(--brown);text-transform:uppercase;letter-spacing:0.5px;display:block;margin-bottom:6px; }
  .form-input,.form-select { width:100%;padding:10px 14px;border:1px solid #ddd;border-radius:8px;font-size:14px;background:white;color:var(--dark);outline:none;font-family:'Lato',sans-serif; }
  .form-input:focus,.form-select:focus{border-color:var(--gold);}
  .form-row { display:grid;grid-template-columns:1fr 1fr;gap:10px; }
  .items-box { border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:14px;background:white; }
  .item-row { display:flex;align-items:center;gap:8px;margin-bottom:8px; }
  .item-row:last-child{margin-bottom:0;}
  .item-remove { background:none;border:none;color:#e74c3c;cursor:pointer;font-size:18px;padding:0 4px; }
  .total-line { display:flex;justify-content:space-between;font-weight:700;font-size:16px;padding-top:12px;border-top:2px solid var(--gold-light);color:var(--dark); }
  .modal-footer { display:flex;gap:8px;justify-content:flex-end;margin-top:1.5rem;padding-top:1rem;border-top:1px solid var(--gold-light); }
  .mbtn { padding:10px 20px;border-radius:20px;border:1px solid #ddd;background:white;color:var(--dark);font-size:14px;cursor:pointer;font-family:'Lato',sans-serif;font-weight:700;transition:all 0.15s; }
  .mbtn:hover{background:#f5f5f5;}
  .mbtn-gold { background:var(--gold);border-color:var(--gold);color:white; }
  .mbtn-gold:hover{background:var(--gold-dark);}
  .mbtn-danger { color:#e74c3c;border-color:#e74c3c; }
  .mbtn-danger:hover{background:#fde8e8;}

  .loading { text-align:center;padding:2rem;color:#aaa;font-size:14px; }
  .empty { text-align:center;padding:2rem;color:#aaa;font-size:14px; }
  .realtime-dot { width:8px;height:8px;border-radius:50%;background:#27ae60;display:inline-block;margin-right:4px;animation:pulse 1.5s infinite; }
</style>
</head>
<body>

<div class="header">
  <div class="logo">
    <div class="logo-icon">&#127874;</div>
    <div>
      <div class="logo-text">GICA Sabores</div>
      <div class="logo-sub"><span class="realtime-dot"></span>Painel Financeiro &#183; Ao vivo</div>
    </div>
  </div>
  <div class="header-right">
    <button class="btn" onclick="exportCSV()">&#11015; Exportar</button>
    <button class="btn btn-gold" onclick="openNovo()">+ Novo pedido</button>
  </div>
</div>

<div class="container">
  <div class="tabs">
    <button class="tab active" onclick="switchTab('pedidos',this)">&#128203; Pedidos</button>
    <button class="tab" onclick="switchTab('relatorio',this)">&#128202; Relat&#243;rio</button>
  </div>

  <div id="tab-pedidos">
    <div class="metrics" id="metrics"><div class="loading">Carregando...</div></div>
    <div class="filters-row">
      <div class="filters">
        <button class="filter-btn active" onclick="setFilter('todos',this)">Todos</button>
        <button class="filter-btn" onclick="setFilter('pendente',this)">Pendentes</button>
        <button class="filter-btn" onclick="setFilter('pago',this)">Pagos</button>
        <button class="filter-btn" onclick="setFilter('atrasado',this)">Atrasados</button>
        <button class="filter-btn" onclick="setFilter('reagendado',this)">Reagendados</button>
      </div>
      <input class="search" id="search" placeholder="&#128269; Buscar..." oninput="renderOrders()">
    </div>
    <div class="orders-list" id="orders-list"><div class="loading">Carregando pedidos...</div></div>
  </div>

  <div id="tab-relatorio" style="display:none">
    <div class="report-grid" id="report-grid"><div class="loading">Carregando...</div></div>
  </div>
</div>

<!-- MODAL -->
<div class="modal" id="modal">
  <div class="modal-bg" onclick="closeModal()"></div>
  <div class="modal-box">
    <div class="modal-title" id="modal-title">Novo pedido</div>
    <div id="modal-body"></div>
    <div class="modal-footer" id="modal-footer"></div>
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
  {nome:'Bolo Lim&#227;o',preco:30},{nome:'Bolo Morango',preco:30},{nome:'Bolo Laranja',preco:30},
  {nome:'Bolo Uva',preco:30},{nome:'Bolo Maracuj&#225;',preco:30},{nome:'Bolo Chocolate',preco:30},{nome:'Bolo C&#244;co',preco:30},
];

let orders = [];
let currentFilter = 'todos';
let editingOrder = null;
let tempItems = [];
let isNew = false;
let lastSeenIds = new Set();

async function loadOrders() {
  const {data,error} = await sb.from('pedidos').select('*').order('created_at',{ascending:false});
  if(error){console.error(error);return;}
  orders = data || [];
  renderAll();
}

function renderAll() { renderMetrics(); renderOrders(); }

function fmtMoney(v){ return 'R$ '+Number(v).toFixed(2).replace('.',','); }
function fmtDate(d){ if(!d)return''; const [y,m,day]=d.split('-'); return `${day}/${m}/${y}`; }
function initials(n){ return n.split(' ').slice(0,2).map(w=>w[0]).join('').toUpperCase(); }
function badgeClass(s){ return {pago:'badge-pago',pendente:'badge-pendente',atrasado:'badge-atrasado',reagendado:'badge-reagendado'}[s]||'badge-pendente'; }
function badgeLabel(s){ return {pago:'&#9989; Pago',pendente:'&#9203; Pendente',atrasado:'&#128308; Atrasado',reagendado:'&#128197; Reagendado'}[s]||s; }

function renderMetrics(){
  const total=orders.reduce((s,o)=>s+Number(o.total),0);
  const pago=orders.filter(o=>o.status==='pago').reduce((s,o)=>s+Number(o.total),0);
  const pendente=orders.filter(o=>o.status!=='pago').reduce((s,o)=>s+Number(o.total),0);
  const atrasados=orders.filter(o=>o.status==='atrasado').length;
  document.getElementById('metrics').innerHTML=`
    <div class="metric"><div class="metric-label">Total Geral</div><div class="metric-value">${fmtMoney(total)}</div><div class="metric-sub">${orders.length} pedidos</div></div>
    <div class="metric success"><div class="metric-label">Recebido</div><div class="metric-value">${fmtMoney(pago)}</div><div class="metric-sub">${orders.filter(o=>o.status==='pago').length} pagos</div></div>
    <div class="metric danger"><div class="metric-label">A Receber</div><div class="metric-value">${fmtMoney(pendente)}</div><div class="metric-sub">${orders.filter(o=>o.status!=='pago').length} pendentes</div></div>
    <div class="metric ${atrasados>0?'danger':''}"><div class="metric-label">Atrasados</div><div class="metric-value">${atrasados}</div><div class="metric-sub">clientes</div></div>
  `;
}

function renderOrders(){
  const search=(document.getElementById('search')||{}).value||'';
  let list=orders.filter(o=>{
    const mf=currentFilter==='todos'||o.status===currentFilter;
    const ms=!search||o.cliente.toLowerCase().includes(search.toLowerCase())||(o.items||[]).some(i=>i.nome.toLowerCase().includes(search.toLowerCase()));
    return mf&&ms;
  });
  const el=document.getElementById('orders-list');
  if(!list.length){el.innerHTML='<div class="empty">Nenhum pedido encontrado</div>';return;}
  el.innerHTML=list.map(o=>`
    <div class="order-card ${o.status}" onclick="openEdit('${o.id}')">
      <div class="order-top">
        <div class="order-client">
          <div class="avatar">${initials(o.cliente)}</div>
          ${o.cliente}
          ${!lastSeenIds.has(o.id)?'<span class="new-badge">NOVO</span>':''}
        </div>
        <div class="order-right">
          <span class="badge ${badgeClass(o.status)}">${badgeLabel(o.status)}</span>
          <span class="order-total">${fmtMoney(o.total)}</span>
        </div>
      </div>
      <div class="order-items">${(o.items||[]).map(i=>`${i.qty}x ${i.nome}`).join(' &#183; ')}</div>
      <div class="order-meta">
        <span class="meta-pill">&#128197; ${fmtDate(o.data_pedido)}</span>
        <span class="meta-pill">${o.pagamento==='pix'?'&#128179;':'&#128181;'} ${o.pagamento.toUpperCase()}</span>
        ${o.telefone?`<span class="meta-pill">&#128241; ${o.telefone}</span>`:''}
        ${o.reagendado_para?`<span class="meta-pill">&#128198; reagendado p/ ${fmtDate(o.reagendado_para)}</span>`:''}
        ${o.obs?`<span class="meta-pill" title="${o.obs}">&#128221; obs</span>`:''}
      </div>
    </div>
  `).join('');
  lastSeenIds=new Set(orders.map(o=>o.id));
}

function setFilter(f,el){
  currentFilter=f;
  document.querySelectorAll('.filter-btn').forEach(b=>b.classList.remove('active'));
  el.classList.add('active');
  renderOrders();
}

function switchTab(tab,el){
  document.querySelectorAll('.tab').forEach(t=>t.classList.remove('active'));
  el.classList.add('active');
  document.getElementById('tab-pedidos').style.display=tab==='pedidos'?'':'none';
  document.getElementById('tab-relatorio').style.display=tab==='relatorio'?'':'none';
  if(tab==='relatorio') renderReport();
}

function renderReport(){
  const meses=['Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'];
  const byMonth={};
  orders.forEach(o=>{
    const m=o.data_pedido.substring(0,7);
    if(!byMonth[m]){byMonth[m]={total:0,pago:0};}
    byMonth[m].total+=Number(o.total);
    if(o.status==='pago') byMonth[m].pago+=Number(o.total);
  });
  const keys=Object.keys(byMonth).sort().slice(-6);
  const maxV=Math.max(...keys.map(k=>byMonth[k].total),1);
  const devedores=orders.filter(o=>o.status!=='pago').sort((a,b)=>Number(b.total)-Number(a.total));
  const pixR=orders.filter(o=>o.pagamento==='pix'&&o.status==='pago').reduce((s,o)=>s+Number(o.total),0);
  const dinR=orders.filter(o=>o.pagamento==='dinheiro'&&o.status==='pago').reduce((s,o)=>s+Number(o.total),0);
  const traR=orders.filter(o=>o.pagamento==='transferencia'&&o.status==='pago').reduce((s,o)=>s+Number(o.total),0);
  const carR=orders.filter(o=>o.pagamento==='cartao'&&o.status==='pago').reduce((s,o)=>s+Number(o.total),0);
  document.getElementById('report-grid').innerHTML=`
    <div class="report-card" style="grid-column:1/-1">
      <h3>Faturamento por m&#234;s</h3>
      ${keys.length?keys.map(k=>{const[y,m]=k.split('-');return`
        <div class="month-bar">
          <span class="month-name">${meses[parseInt(m)-1]}</span>
          <div class="bar-track"><div class="bar-fill" style="width:${(byMonth[k].total/maxV*100).toFixed(1)}%"></div></div>
          <span class="month-val">${fmtMoney(byMonth[k].total)}</span>
        </div>`}).join(''):'<div class="empty">Sem dados ainda</div>'}
    </div>
    <div class="report-card">
      <h3>Quem deve (${devedores.length})</h3>
      ${devedores.length===0?'<div style="color:#27ae60;font-size:13px">&#127881; Todos em dia!</div>':devedores.map(o=>`
        <div class="debtor-row">
          <div><div style="font-weight:700;font-size:13px">${o.cliente}</div>
          <div style="font-size:11px;color:#aaa">${fmtDate(o.data_pedido)} &#183; ${o.status}${o.reagendado_para?' &#8594; '+fmtDate(o.reagendado_para):''}</div></div>
          <span style="color:#e74c3c;font-weight:700;font-size:13px">${fmtMoney(o.total)}</span>
        </div>`).join('')}
    </div>
    <div class="report-card">
      <h3>Formas de pagamento</h3>
      <div class="pix-row"><span>&#128179; Pix</span><span style="font-weight:700">${fmtMoney(pixR)}</span></div>
      <div class="pix-row"><span>&#128181; Dinheiro</span><span style="font-weight:700">${fmtMoney(dinR)}</span></div>
      <div class="pix-row"><span>&#127974; Transfer&#234;ncia</span><span style="font-weight:700">${fmtMoney(traR)}</span></div>
      <div class="pix-row"><span>&#128179; Cart&#227;o</span><span style="font-weight:700">${fmtMoney(carR)}</span></div>
      <div class="pix-row" style="border-top:2px solid var(--gold-light);margin-top:4px;padding-top:8px">
        <span style="font-weight:700">Total recebido</span>
        <span style="font-weight:700;color:#1a7a4a">${fmtMoney(pixR+dinR+traR+carR)}</span>
      </div>
    </div>
  `;
}

// MODAL
function buildModalBody(order){
  return `
    <div class="form-group">
      <label class="form-label">Nome do cliente</label>
      <input class="form-input" id="f-cliente" placeholder="Nome completo" value="${order?order.cliente:''}">
    </div>
    <div class="form-row">
      <div class="form-group">
        <label class="form-label">WhatsApp</label>
        <input class="form-input" id="f-tel" placeholder="(11) 99999-9999" value="${order?order.telefone||'':''}">
      </div>
      <div class="form-group">
        <label class="form-label">Data</label>
        <input class="form-input" type="date" id="f-data" value="${order?order.data_pedido:new Date().toISOString().slice(0,10)}">
      </div>
    </div>
    <div class="form-row">
      <div class="form-group">
        <label class="form-label">Status</label>
        <select class="form-select" id="f-status" onchange="toggleReag()">
          <option value="pendente" ${order&&order.status==='pendente'?'selected':''}>&#9203; Pendente</option>
          <option value="pago" ${order&&order.status==='pago'?'selected':''}>&#9989; Pago</option>
          <option value="atrasado" ${order&&order.status==='atrasado'?'selected':''}>&#128308; Atrasado</option>
          <option value="reagendado" ${order&&order.status==='reagendado'?'selected':''}>&#128197; Reagendado</option>
        </select>
      </div>
      <div class="form-group">
        <label class="form-label">Pagamento</label>
        <select class="form-select" id="f-pagamento">
          <option value="pix" ${order&&order.pagamento==='pix'?'selected':''}>&#128179; Pix</option>
          <option value="dinheiro" ${order&&order.pagamento==='dinheiro'?'selected':''}>&#128181; Dinheiro</option>
          <option value="transferencia" ${order&&order.pagamento==='transferencia'?'selected':''}>&#127974; Transfer&#234;ncia</option>
          <option value="cartao" ${order&&order.pagamento==='cartao'?'selected':''}>&#128179; Cart&#227;o</option>
        </select>
      </div>
    </div>
    <div class="form-group" id="reag-group" style="display:${order&&order.status==='reagendado'?'':'none'}">
      <label class="form-label">Reagendado para</label>
      <input class="form-input" type="date" id="f-reagendado" value="${order?order.reagendado_para||'':''}">
    </div>
    <div class="form-group">
      <label class="form-label">Itens do pedido</label>
      <div class="items-box" id="items-box">
        ${buildItemsHTML()}
        <button class="mbtn" onclick="addItem()" style="width:100%;margin-top:${tempItems.length?'8px':'0'}">+ Adicionar item</button>
      </div>
      <div class="total-line"><span>Total</span><span id="items-total">${fmtMoney(calcTotal())}</span></div>
    </div>
    <div class="form-group">
      <label class="form-label">Observa&#231;&#227;o</label>
      <input class="form-input" id="f-obs" placeholder="Prometeu pagar na sexta, entregar &#224;s 18h..." value="${order?order.obs||'':''}">
    </div>
  `;
}

function buildItemsHTML(){
  return tempItems.map((item,i)=>`
    <div class="item-row">
      <input class="form-input" type="number" min="1" value="${item.qty}" onchange="updQty(${i},this.value)" style="width:60px">
      <select class="form-select" onchange="updName(${i},this.value)" style="flex:1">
        ${CARDAPIO.map(p=>`<option value="${p.nome}|${p.preco}" ${p.nome===item.nome?'selected':''}>${p.nome} &#8211; R$${p.preco}</option>`).join('')}
      </select>
      <button class="item-remove" onclick="removeItem(${i})">&#128465;</button>
    </div>
  `).join('');
}

function calcTotal(){ return tempItems.reduce((s,i)=>s+(i.preco*i.qty),0); }
function updQty(i,v){ tempItems[i].qty=parseInt(v)||1; refreshTotal(); }
function updName(i,v){ const[n,p]=v.split('|'); tempItems[i].nome=n; tempItems[i].preco=parseFloat(p); refreshTotal(); }
function refreshTotal(){ const el=document.getElementById('items-total'); if(el) el.textContent=fmtMoney(calcTotal()); }
function removeItem(i){ tempItems.splice(i,1); document.getElementById('modal-body').innerHTML=buildModalBody(editingOrder); }
function addItem(){ tempItems.push({nome:CARDAPIO[0].nome,qty:1,preco:CARDAPIO[0].preco}); document.getElementById('modal-body').innerHTML=buildModalBody(editingOrder); }
function toggleReag(){ const v=document.getElementById('f-status').value; document.getElementById('reag-group').style.display=v==='reagendado'?'':'none'; }

function openNovo(){
  editingOrder=null; isNew=true;
  tempItems=[{nome:CARDAPIO[0].nome,qty:1,preco:CARDAPIO[0].preco}];
  document.getElementById('modal-title').textContent='Novo pedido';
  document.getElementById('modal-body').innerHTML=buildModalBody(null);
  document.getElementById('modal-footer').innerHTML=`<button class="mbtn" onclick="closeModal()">Cancelar</button><button class="mbtn mbtn-gold" onclick="saveOrder()">&#9989; Salvar</button>`;
  document.getElementById('modal').classList.add('open');
}

function openEdit(id){
  editingOrder=orders.find(o=>o.id===id);
  if(!editingOrder)return;
  isNew=false;
  tempItems=(editingOrder.items||[]).map(i=>({...i}));
  document.getElementById('modal-title').textContent='Editar pedido';
  document.getElementById('modal-body').innerHTML=buildModalBody(editingOrder);
  document.getElementById('modal-footer').innerHTML=`
    <button class="mbtn mbtn-danger" onclick="deleteOrder('${id}')">&#128465; Excluir</button>
    <div style="flex:1"></div>
    <button class="mbtn" onclick="closeModal()">Cancelar</button>
    <button class="mbtn mbtn-gold" onclick="saveOrder()">&#9989; Salvar</button>
  `;
  document.getElementById('modal').classList.add('open');
}

async function saveOrder(){
  const cliente=document.getElementById('f-cliente').value.trim();
  if(!cliente){alert('Informe o nome do cliente');return;}
  if(!tempItems.length){alert('Adicione pelo menos um item');return;}
  const status=document.getElementById('f-status').value;
  const payload={
    cliente,
    telefone:document.getElementById('f-tel').value,
    items:tempItems,
    total:calcTotal(),
    status,
    pagamento:document.getElementById('f-pagamento').value,
    data_pedido:document.getElementById('f-data').value,
    obs:document.getElementById('f-obs').value,
    reagendado_para:status==='reagendado'?(document.getElementById('f-reagendado').value||null):null,
  };
  if(isNew){
    await sb.from('pedidos').insert(payload);
  } else {
    await sb.from('pedidos').update(payload).eq('id',editingOrder.id);
  }
  closeModal();
  await loadOrders();
}

async function deleteOrder(id){
  if(!confirm('Excluir este pedido?'))return;
  await sb.from('pedidos').delete().eq('id',id);
  closeModal();
  await loadOrders();
}

function closeModal(){ document.getElementById('modal').classList.remove('open'); }

function exportCSV(){
  const csv=['Cliente,Tel,Items,Total,Status,Pagamento,Data,Obs',
    ...orders.map(o=>`"${o.cliente}","${o.telefone||''}","${(o.items||[]).map(i=>i.qty+'x '+i.nome).join('; ')}","${fmtMoney(o.total)}","${o.status}","${o.pagamento}","${fmtDate(o.data_pedido)}","${o.obs||''}"`)
  ].join('\n');
  const url=URL.createObjectURL(new Blob(['\uFEFF'+csv,{type:'text/csv;charset=utf-8'}]));
  const a=document.createElement('a');a.href=url;a.download='gica-pedidos.csv';a.click();
}

// REALTIME &#8212; atualiza ao vivo quando chega pedido novo do card&#225;pio
sb.channel('pedidos-changes')
  .on('postgres_changes',{event:'INSERT',schema:'public',table:'pedidos'},()=>{
    loadOrders();
  })
  .subscribe();

loadOrders();
</script>
</body>
</html>

'@
[System.IO.File]::WriteAllText("$PWD\Painel GICA.html", $p, [System.Text.Encoding]::UTF8)
Write-Host "[OK] Painel GICA.html corrigido" -ForegroundColor Green

Write-Host ""
Write-Host "Agora rode: git add . && git commit -m fix && git push" -ForegroundColor Yellow
