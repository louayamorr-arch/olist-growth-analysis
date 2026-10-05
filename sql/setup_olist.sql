-- ===== setup_olist.sql =====
SET client_encoding TO 'UTF8';   -- Portuguese accents load correctly

DROP TABLE IF EXISTS customers, orders, order_items, payments, reviews,
  products, sellers, geolocation, category_translation;

CREATE TABLE customers (
  customer_id              TEXT PRIMARY KEY,
  customer_unique_id       TEXT,
  customer_zip_code_prefix TEXT,          -- TEXT keeps leading zeros
  customer_city            TEXT,
  customer_state           CHAR(2)
);

CREATE TABLE orders (
  order_id                      TEXT PRIMARY KEY,
  customer_id                   TEXT,
  order_status                  TEXT,
  order_purchase_timestamp      TIMESTAMP,
  order_approved_at             TIMESTAMP,
  order_delivered_carrier_date  TIMESTAMP,
  order_delivered_customer_date TIMESTAMP,
  order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE order_items (
  order_id            TEXT,
  order_item_id       INT,
  product_id          TEXT,
  seller_id           TEXT,
  shipping_limit_date TIMESTAMP,
  price               NUMERIC(10,2),
  freight_value       NUMERIC(10,2),
  PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE payments (
  order_id             TEXT,
  payment_sequential   INT,
  payment_type         TEXT,
  payment_installments INT,
  payment_value        NUMERIC(10,2),
  PRIMARY KEY (order_id, payment_sequential)
);

CREATE TABLE reviews (               -- no PK: review_id has duplicates in the source
  review_id               TEXT,
  order_id                TEXT,
  review_score            SMALLINT,
  review_comment_title    TEXT,
  review_comment_message  TEXT,
  review_creation_date    TIMESTAMP,
  review_answer_timestamp TIMESTAMP
);

CREATE TABLE products (
  product_id                 TEXT PRIMARY KEY,
  product_category_name      TEXT,
  product_name_lenght        INT,     -- typo is in the original data
  product_description_lenght INT,
  product_photos_qty         INT,
  product_weight_g           INT,
  product_length_cm          INT,
  product_height_cm          INT,
  product_width_cm           INT
);

CREATE TABLE sellers (
  seller_id              TEXT PRIMARY KEY,
  seller_zip_code_prefix TEXT,
  seller_city            TEXT,
  seller_state           CHAR(2)
);

CREATE TABLE geolocation (           
  geolocation_zip_code_prefix TEXT,
  geolocation_lat             DOUBLE PRECISION,
  geolocation_lng             DOUBLE PRECISION,
  geolocation_city            TEXT,
  geolocation_state           CHAR(2)
);

CREATE TABLE category_translation (
  product_category_name         TEXT PRIMARY KEY,
  product_category_name_english TEXT
);

-- ===== Load CSVs (client-side \copy, so no file-permission issues) =====
\copy customers            FROM 'C:/Users/User/Desktop/SQL Learning/olist/data/olist_customers_dataset.csv'       WITH (FORMAT csv, HEADER true)
\copy orders               FROM 'C:/Users/User/Desktop/SQL Learning/olist/data/olist_orders_dataset.csv'          WITH (FORMAT csv, HEADER true)
\copy order_items          FROM 'C:/Users/User/Desktop/SQL Learning/olist/data/olist_order_items_dataset.csv'     WITH (FORMAT csv, HEADER true)
\copy payments             FROM 'C:/Users/User/Desktop/SQL Learning/olist/data/olist_order_payments_dataset.csv'  WITH (FORMAT csv, HEADER true)
\copy reviews              FROM 'C:/Users/User/Desktop/SQL Learning/olist/data/olist_order_reviews_dataset.csv'   WITH (FORMAT csv, HEADER true)
\copy products             FROM 'C:/Users/User/Desktop/SQL Learning/olist/data/olist_products_dataset.csv'        WITH (FORMAT csv, HEADER true)
\copy sellers              FROM 'C:/Users/User/Desktop/SQL Learning/olist/data/olist_sellers_dataset.csv'         WITH (FORMAT csv, HEADER true)
\copy geolocation          FROM 'C:/Users/User/Desktop/SQL Learning/olist/data/olist_geolocation_dataset.csv'     WITH (FORMAT csv, HEADER true)
\copy category_translation FROM 'C:/Users/User/Desktop/SQL Learning/olist/data/product_category_name_translation.csv' WITH (FORMAT csv, HEADER true)

ALTER TABLE orders      ADD CONSTRAINT fk_orders_customer  FOREIGN KEY (customer_id) REFERENCES customers(customer_id);
ALTER TABLE order_items ADD CONSTRAINT fk_items_order      FOREIGN KEY (order_id)    REFERENCES orders(order_id);
ALTER TABLE order_items ADD CONSTRAINT fk_items_product    FOREIGN KEY (product_id)  REFERENCES products(product_id);
ALTER TABLE order_items ADD CONSTRAINT fk_items_seller     FOREIGN KEY (seller_id)   REFERENCES sellers(seller_id);
ALTER TABLE payments    ADD CONSTRAINT fk_payments_order   FOREIGN KEY (order_id)    REFERENCES orders(order_id);
ALTER TABLE reviews     ADD CONSTRAINT fk_reviews_order    FOREIGN KEY (order_id)    REFERENCES orders(order_id);