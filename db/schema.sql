CREATE TABLE IF NOT EXISTS "addresses" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "city" TEXT,
    "street_name" TEXT,
    "street_address" TEXT,
    "person_id" INTEGER
);

CREATE TABLE IF NOT EXISTS "people" (
    "first_name" TEXT,
    "last_name" TEXT,
    "credit_card" TEXT,
    "phone" TEXT,
    "email" TEXT,
    "title" TEXT,
    "id" INTEGER PRIMARY KEY AUTOINCREMENT
);

CREATE TABLE IF NOT EXISTS "mixed_people" (
    "first_name" TEXT,
    "last_name" TEXT,
    "id" INTEGER PRIMARY KEY AUTOINCREMENT
);

CREATE TABLE IF NOT EXISTS "mixed_addresses" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "street_name" TEXT,
    "street_address" TEXT,
    "person_id" INTEGER
);
