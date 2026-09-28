CREATE TABLE IF NOT EXISTS radio_channels (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    frequency FLOAT NOT NULL
);

INSERT INTO radio_channels (name, frequency) VALUES ('Radio Channel 1', 1.0);
INSERT INTO radio_channels (name, frequency) VALUES ('Radio Channel 2', 2.0);
INSERT INTO radio_channels (name, frequency) VALUES ('Radio Channel 3', 3.0);

CREATE TABLE IF NOT EXISTS player_radio (
    player_id INT NOT NULL,
    channel_id INT NOT NULL,
    volume FLOAT NOT NULL,
    PRIMARY KEY (player_id),
    FOREIGN KEY (player_id) REFERENCES users(identifier),
    FOREIGN KEY (channel_id) REFERENCES radio_channels(id)
);