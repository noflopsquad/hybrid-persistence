CREATE TABLE IF NOT EXISTS "addresses" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "city" TEXT,
    "country" TEXT,
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
    "nickname" TEXT,
    "id" INTEGER PRIMARY KEY AUTOINCREMENT
);
CREATE TABLE IF NOT EXISTS "mixed_people" (
    "id" INTEGER PRIMARY KEY,
    "first_name" TEXT,
    "last_name" TEXT
);
CREATE TABLE IF NOT EXISTS "mixed_addresses" (
    "street_name" TEXT,
    "street_address" TEXT,
    "person_id" INTEGER,
    PRIMARY KEY ("street_name", "street_address"),
    FOREIGN KEY ("person_id") REFERENCES mixed_people("id")
);
