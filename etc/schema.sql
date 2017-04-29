
CREATE TABLE rates (
    id INTEGER,
    name VARCHAR,
    value DOUBLE,
    PRIMARY KEY ( id )
);

CREATE TABLE bonds (
    id INTEGER,
    name VARCHAR,
    value DOUBLE,
    PRIMARY KEY ( id )
);

CREATE TABLE fx (
    id INTEGER,
    name VARCHAR,
    value DOUBLE,
    PRIMARY KEY ( id )
);

INSERT INTO rates (name, value) VALUES ( 'usd_1y', 1.005 );
INSERT INTO rates (name, value) VALUES ( 'usd_5y', 1.020 );
INSERT INTO rates (name, value) VALUES ( 'usd_10y', 1.050 );
INSERT INTO rates (name, value) VALUES ( 'usd_20y', 1.105 );
INSERT INTO rates (name, value) VALUES ( 'usd_25y', 1.120 );
INSERT INTO rates (name, value) VALUES ( 'usd_50y', 1.250 );
