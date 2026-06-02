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
