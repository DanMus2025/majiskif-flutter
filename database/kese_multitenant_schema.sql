-- KESE multi-tenant schema
-- Local offline target: SQLite (Android / Desktop)
-- Central online target: PostgreSQL
-- The same business identifiers are used on both sides.

CREATE TABLE IF NOT EXISTS tenants (
  tenant_id TEXT PRIMARY KEY,
  license_code TEXT NOT NULL UNIQUE,
  company_name TEXT NOT NULL,
  owner_name TEXT,
  phone TEXT,
  email TEXT,
  address TEXT,
  logo_url TEXT,
  rccm TEXT,
  id_nat TEXT,
  nif TEXT,
  efo TEXT,
  currency_code TEXT NOT NULL DEFAULT 'FC',
  tax_rate NUMERIC NOT NULL DEFAULT 0,
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS branches (
  branch_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  branch_name TEXT NOT NULL,
  city TEXT,
  address TEXT,
  is_main_branch INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id)
);

CREATE TABLE IF NOT EXISTS devices (
  device_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  branch_id TEXT NOT NULL,
  device_label TEXT NOT NULL,
  platform_name TEXT NOT NULL,
  last_seen_at TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
  FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

CREATE TABLE IF NOT EXISTS app_users (
  user_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  branch_id TEXT NOT NULL,
  full_name TEXT NOT NULL,
  username TEXT NOT NULL,
  username_normalized TEXT NOT NULL,
  role_name TEXT NOT NULL,
  pin_hash TEXT NOT NULL,
  is_blocked INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
  FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
  UNIQUE (tenant_id, username_normalized)
);

CREATE TABLE IF NOT EXISTS categories (
  category_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  category_name TEXT NOT NULL,
  created_at TEXT NOT NULL,
  UNIQUE (tenant_id, category_name),
  FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id)
);

CREATE TABLE IF NOT EXISTS products (
  product_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  branch_id TEXT NOT NULL,
  category_id TEXT,
  sku TEXT NOT NULL,
  barcode TEXT NOT NULL,
  product_name TEXT NOT NULL,
  unit_name TEXT NOT NULL,
  cost_amount NUMERIC NOT NULL DEFAULT 0,
  price_amount NUMERIC NOT NULL DEFAULT 0,
  quantity_on_hand NUMERIC NOT NULL DEFAULT 0,
  min_quantity NUMERIC NOT NULL DEFAULT 0,
  location_label TEXT,
  image_url TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
  FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
  FOREIGN KEY (category_id) REFERENCES categories(category_id),
  UNIQUE (tenant_id, sku),
  UNIQUE (tenant_id, barcode)
);

CREATE TABLE IF NOT EXISTS customers (
  customer_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  full_name TEXT NOT NULL,
  phone TEXT,
  address TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id)
);

CREATE TABLE IF NOT EXISTS suppliers (
  supplier_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  supplier_name TEXT NOT NULL,
  phone TEXT,
  address TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id)
);

CREATE TABLE IF NOT EXISTS sales (
  sale_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  branch_id TEXT NOT NULL,
  order_no TEXT NOT NULL,
  invoice_no TEXT NOT NULL,
  ticket_no TEXT NOT NULL,
  customer_id TEXT NOT NULL,
  cashier_id TEXT NOT NULL,
  subtotal_amount NUMERIC NOT NULL DEFAULT 0,
  discount_amount NUMERIC NOT NULL DEFAULT 0,
  total_amount NUMERIC NOT NULL DEFAULT 0,
  paid_amount NUMERIC NOT NULL DEFAULT 0,
  payment_method TEXT NOT NULL,
  due_date TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
  FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (cashier_id) REFERENCES app_users(user_id),
  UNIQUE (tenant_id, invoice_no),
  UNIQUE (tenant_id, ticket_no),
  UNIQUE (tenant_id, order_no)
);

CREATE TABLE IF NOT EXISTS sale_lines (
  sale_line_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  sale_id TEXT NOT NULL,
  product_id TEXT NOT NULL,
  quantity NUMERIC NOT NULL,
  unit_price NUMERIC NOT NULL,
  unit_cost NUMERIC NOT NULL,
  line_total NUMERIC NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
  FOREIGN KEY (sale_id) REFERENCES sales(sale_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE IF NOT EXISTS purchases (
  purchase_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  branch_id TEXT NOT NULL,
  reference_no TEXT NOT NULL,
  product_id TEXT NOT NULL,
  supplier_id TEXT NOT NULL,
  quantity NUMERIC NOT NULL,
  total_amount NUMERIC NOT NULL,
  paid_amount NUMERIC NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
  FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id),
  FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
  UNIQUE (tenant_id, reference_no)
);

CREATE TABLE IF NOT EXISTS expenses (
  expense_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  branch_id TEXT NOT NULL,
  label TEXT NOT NULL,
  amount NUMERIC NOT NULL,
  created_by_user_id TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
  FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
  FOREIGN KEY (created_by_user_id) REFERENCES app_users(user_id)
);

CREATE TABLE IF NOT EXISTS stock_moves (
  move_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  branch_id TEXT NOT NULL,
  product_id TEXT NOT NULL,
  move_type TEXT NOT NULL,
  quantity_delta NUMERIC NOT NULL,
  reference_no TEXT NOT NULL,
  created_by_user_id TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
  FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id),
  FOREIGN KEY (created_by_user_id) REFERENCES app_users(user_id)
);

CREATE TABLE IF NOT EXISTS app_messages (
  message_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  sender_user_id TEXT,
  recipient_user_id TEXT,
  message_type TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  read_at TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
  FOREIGN KEY (sender_user_id) REFERENCES app_users(user_id),
  FOREIGN KEY (recipient_user_id) REFERENCES app_users(user_id)
);

CREATE TABLE IF NOT EXISTS app_alerts (
  alert_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  level_name TEXT NOT NULL,
  read_at TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id)
);

CREATE TABLE IF NOT EXISTS sync_queue (
  queue_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  branch_id TEXT NOT NULL,
  device_id TEXT NOT NULL,
  entity_name TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  operation_name TEXT NOT NULL,
  payload_json TEXT NOT NULL,
  payload_hash TEXT NOT NULL,
  sync_status TEXT NOT NULL DEFAULT 'pending',
  retry_count INTEGER NOT NULL DEFAULT 0,
  last_error TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
  FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
  FOREIGN KEY (device_id) REFERENCES devices(device_id)
);

CREATE TABLE IF NOT EXISTS sync_conflicts (
  conflict_id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  branch_id TEXT NOT NULL,
  device_id TEXT NOT NULL,
  entity_name TEXT NOT NULL,
  local_entity_id TEXT NOT NULL,
  server_entity_id TEXT,
  conflict_type TEXT NOT NULL,
  local_payload_json TEXT NOT NULL,
  server_payload_json TEXT,
  resolution_status TEXT NOT NULL DEFAULT 'open',
  created_at TEXT NOT NULL,
  resolved_at TEXT,
  FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id),
  FOREIGN KEY (branch_id) REFERENCES branches(branch_id),
  FOREIGN KEY (device_id) REFERENCES devices(device_id)
);

CREATE INDEX IF NOT EXISTS idx_users_tenant_role
  ON app_users (tenant_id, role_name);

CREATE INDEX IF NOT EXISTS idx_sales_tenant_created
  ON sales (tenant_id, created_at);

CREATE INDEX IF NOT EXISTS idx_queue_tenant_status
  ON sync_queue (tenant_id, sync_status, created_at);

CREATE INDEX IF NOT EXISTS idx_conflicts_tenant_status
  ON sync_conflicts (tenant_id, resolution_status, created_at);
