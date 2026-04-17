# Database Architecture (Detailed)

## 1) ERD (Entity Relationship Diagram)
```mermaid
erDiagram
    USERS ||--o{ ORDERS : places
    PRODUCTS ||--o{ ORDER_ITEMS : ordered_as
    ORDERS ||--|{ ORDER_ITEMS : has_lines
    ORDERS ||--o{ PAYMENTS : receives
    PAYMENTS ||--o{ REFUNDS : may_generate
<<<<<<< ours
=======
    PAYMENTS ||--o{ AUDIT_LOGS : records
    ORDERS ||--o{ AUDIT_LOGS : context
    USERS ||--o{ AUDIT_LOGS : actor
>>>>>>> theirs
```

## 2) Table Responsibilities

### `users`
- Primary account table.
- Contains identity + authentication fields:
  - `full_name`, `email`, `password_hash`.
- `address` is updated during checkout to keep delivery details current.

### `products`
- Product catalog + inventory.
- Includes category, price, and stock.
- `is_active` allows soft on/off visibility without deleting products.

### `orders`
- Order header record.
- Links to `users` via `user_id`.
- Stores `shipping_address` snapshot and workflow status (`Pending`, `Paid`, etc.).

### `order_items`
- Order line table.
- Links each purchased product to its order.
- Keeps `unit_price` + `subtotal` so historical totals remain stable even if product prices change later.

### `payments`
- Payment event table for each order.
- Tracks method, amount, and status progression.

### `refunds`
- Refund audit table linked to `payments`.
- Preserves reason, amount, and lifecycle state.

## 3) Data Flow
1. User signs up (`users` row created).
2. User logs in (credentials checked against `users`).
3. User adds items to cart (session-side, then persisted at checkout).
4. Checkout updates `users.address`, then calls:
   - `sp_PlaceOrder` (order + line + stock deduction)
   - `sp_ProcessPayment` (payment row + order status update)
5. Optional refund calls `sp_ProcessRefund`.

## 4) Transaction and Consistency Strategy
- `sp_PlaceOrder` uses a transaction and `FOR UPDATE` stock lock.
- Stock is validated before order insertion.
- A single place handles stock decrement and line subtotal calculation.
- This reduces race conditions and keeps financial/inventory values consistent.

<<<<<<< ours
## 5) Why this design works for DBMS coursework
- Demonstrates **normalization** (separate users, products, order header, order lines, payments, refunds).
- Demonstrates **relational integrity** (FK constraints across all transactional tables).
- Demonstrates **database programming** (stored function + procedures).
=======
## 5) Trigger Strategy (Rubric Alignment)
### `trg_before_order_item_insert`
- Type: `BEFORE INSERT` on `order_items`.
- Rules enforced:
  - quantity must be greater than zero,
  - subtotal is recalculated by `fn_line_subtotal`.
- Benefit: guards data quality even if a direct SQL insert bypasses PHP code.

### `trg_after_payment_insert`
- Type: `AFTER INSERT` on `payments`.
- Action:
  - writes a record in `audit_logs` with payment, order, and user references.
- Benefit: establishes an auditable backend trail for completed payments.

## 6) Why this design works for DBMS coursework
- Demonstrates **normalization** (separate users, products, order header, order lines, payments, refunds).
- Demonstrates **relational integrity** (FK constraints across all transactional tables).
- Demonstrates **database programming** (stored function + procedures + triggers).
>>>>>>> theirs
- Demonstrates **business rules in SQL** (stock checks, payment/refund lifecycle).
