CREATE TABLE IF NOT EXISTS "addresses" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "city" TEXT,
    "country" TEXT,
    "street_name" TEXT,
    "street_address" TEXT,
    "person_id" INTEGER
);
CREATE TABLE IF NOT EXISTS "archived_addresses" (
    "street_name" TEXT,
    "street_address" TEXT,
    "archivation_time" INTEGER,
    "city" TEXT,
    "country" TEXT,
    "first_name" TEXT,
    "last_name" TEXT,
    PRIMARY KEY ("street_name", "street_address", "archivation_time"),
    FOREIGN KEY ("first_name", "last_name", "archivation_time")
    REFERENCES archived_people("first_name", "last_name", "archivation_time")
);
CREATE TABLE IF NOT EXISTS "archived_people" (
    "archivation_time" INTEGER,
    "first_name" TEXT,
    "last_name" TEXT,
    "credit_card" TEXT,
    "phone" TEXT,
    "email" TEXT,
    "title" TEXT,
    "nickname" TEXT,
    PRIMARY KEY ("first_name", "last_name", "archivation_time")
);
CREATE TABLE IF NOT EXISTS "people" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "first_name" TEXT,
    "last_name" TEXT,
    "credit_card" TEXT,
    "phone" TEXT,
    "email" TEXT,
    "title" TEXT,
    "nickname" TEXT
);
CREATE TABLE IF NOT EXISTS "hybrid_people" (
    "id" INTEGER PRIMARY KEY,
    "first_name" TEXT,
    "last_name" TEXT
);
CREATE TABLE IF NOT EXISTS "hybrid_addresses" (
    "street_name" TEXT,
    "street_address" TEXT,
    "person_id" INTEGER,
    PRIMARY KEY ("street_name", "street_address"),
    FOREIGN KEY ("person_id") REFERENCES hybrid_people("id")
);
