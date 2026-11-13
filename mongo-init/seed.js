// Runs once, when the mongo-data volume is first initialised.
// Creates a small sample database so there is something to explore in Compass.
const shop = db.getSiblingDB('poc_shop');

shop.customers.insertMany([
  { _id: 1, name: 'Asha Verma',   city: 'Bengaluru', tier: 'gold',   joined: new Date('2024-02-11') },
  { _id: 2, name: 'Rahul Mehta',  city: 'Pune',      tier: 'silver', joined: new Date('2024-07-03') },
  { _id: 3, name: 'Priya Nair',   city: 'Kochi',     tier: 'gold',   joined: new Date('2025-01-19') },
  { _id: 4, name: 'Vikram Singh', city: 'Delhi',     tier: 'bronze', joined: new Date('2025-06-27') },
]);

shop.orders.insertMany([
  { customerId: 1, items: [{ sku: 'KB-01', qty: 1, price: 2499 }], status: 'delivered', placed: new Date('2026-09-02') },
  { customerId: 1, items: [{ sku: 'MS-07', qty: 2, price: 799 }],  status: 'shipped',   placed: new Date('2026-10-14') },
  { customerId: 2, items: [{ sku: 'HD-22', qty: 1, price: 5999 }], status: 'delivered', placed: new Date('2026-08-21') },
  { customerId: 3, items: [{ sku: 'KB-01', qty: 1, price: 2499 },
                           { sku: 'PD-03', qty: 1, price: 399 }],  status: 'pending',   placed: new Date('2026-11-10') },
]);

shop.orders.createIndex({ customerId: 1, placed: -1 });
