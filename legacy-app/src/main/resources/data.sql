INSERT INTO users (username, password, display_name) VALUES
('admin', 'password', '管理者');

INSERT INTO books (title, author, isbn, category, published_year, deleted) VALUES
('吾輩は猫である', '夏目漱石', '9784101010014', 'NOVEL', 1905, FALSE),
('坊っちゃん', '夏目漱石', '9784101010038', 'NOVEL', 1906, FALSE),
('銀河鉄道の夜', '宮沢賢治', '9784101098012', 'NOVEL', 1934, FALSE),
('Java入門', '山田太郎', '9784774186054', 'TECH', 2022, FALSE),
('Spring Boot実践', '田中一郎', '9784798166186', 'TECH', 2023, FALSE),
('クリーンアーキテクチャ', 'Robert C. Martin', '9784048930659', 'TECH', 2018, FALSE),
('広辞苑 第七版', '新村出', '9784000801218', 'REFERENCE', 2018, FALSE),
('JIS規格集', '日本規格協会', '9784542165564', 'REFERENCE', 2020, FALSE),
('星の王子さま', 'サン=テグジュペリ', '9784101264028', 'NOVEL', 1943, FALSE),
('ドラゴンクエスト小説', '堀井雄二', '9784086199352', 'OTHER', 2020, FALSE);
