-- =========================================
-- DATABASE
-- =========================================
CREATE DATABASE IF NOT EXISTS db_kampus;
USE db_kampus;

-- =========================================
-- TABEL MAHASISWA
-- =========================================
CREATE TABLE mahasiswa (
    nim VARCHAR(20) PRIMARY KEY,
    nama VARCHAR(50),
    semester INT,
    prodi VARCHAR(50)
);

INSERT INTO mahasiswa VALUES
('IK2411028','Mifta Auliya',4,'Informatika'),
('IK2411012','Lilis',4,'Informatika');

-- =========================================
-- TABEL AKADEMIK
-- =========================================
CREATE TABLE akademik (
    nim VARCHAR(20),
    sks INT,
    ipk DECIMAL(3,2),
    status_pembayaran VARCHAR(10)
);

INSERT INTO akademik VALUES
('IK2411028',16,3.20,'LUNAS'),
('IK2411012',20,3.60,'LUNAS');

-- =========================================
-- BAGIAN A: IDENTITAS
-- =========================================
DELIMITER //

DROP PROCEDURE IF EXISTS identitas_mhs_tabel //

CREATE PROCEDURE identitas_mhs_tabel()
BEGIN
    DECLARE kampus VARCHAR(100) DEFAULT 'Universitas Mega Buana Palopo';

    SELECT CONCAT(
        'Mahasiswa ', nama, ' (', nim, ') dari Program Studi ', prodi,
        ' terdaftar di ', kampus, ' pada semester ', semester, '.'
    ) AS identitas
    FROM mahasiswa;
END //

DELIMITER ;

CALL identitas_mhs_tabel();

-- =========================================
-- BAGIAN B: VALIDASI
-- =========================================
DELIMITER //

DROP PROCEDURE IF EXISTS bagianB_validasi //

CREATE PROCEDURE bagianB_validasi()
BEGIN
    SELECT 
        
        CONCAT('Status data: ',
            CASE 
                WHEN a.status_pembayaran = 'LUNAS' 
                     AND m.semester > 0 
                     AND a.sks > 0 
                THEN 'Valid'
                ELSE 'Tidak Valid'
            END
        ) AS status_data,

        CONCAT('Beban studi: ',
            CASE 
                WHEN a.sks BETWEEN 1 AND 12 THEN 'Ringan'
                WHEN a.sks BETWEEN 13 AND 18 THEN 'Sedang'
                ELSE 'Padat'
            END
        ) AS beban_studi,

        CONCAT('Performa akademik: ',
            CASE 
                WHEN a.ipk >= 3.50 THEN 'Sangat Baik'
                WHEN a.ipk >= 3.00 THEN 'Baik'
                WHEN a.ipk >= 2.50 THEN 'Cukup'
                ELSE 'Perlu Pembinaan'
            END
        ) AS performa

    FROM mahasiswa m
    JOIN akademik a ON m.nim = a.nim;
END //

DELIMITER ;

CALL bagianB_validasi();

-- =========================================
-- BAGIAN C: KRS
-- =========================================
DELIMITER //

DROP PROCEDURE IF EXISTS bagianC_krs //

CREATE PROCEDURE bagianC_krs()
BEGIN
    SELECT CONCAT(
        'Mahasiswa ', m.nama, ' dengan NIM ', m.nim,
        ' dinyatakan ',

        CASE 
            WHEN a.status_pembayaran = 'LUNAS' 
                 AND m.semester > 0 
                 AND a.sks > 0 
            THEN 'layak mengambil KRS'
            ELSE 'tidak layak mengambil KRS'
        END,

        '. Beban studi berada pada kategori ',

        CASE 
            WHEN a.sks BETWEEN 1 AND 12 THEN 'Ringan'
            WHEN a.sks BETWEEN 13 AND 18 THEN 'Sedang'
            ELSE 'Padat'
        END,

        ' dengan performa akademik ',

        CASE 
            WHEN a.ipk >= 3.50 THEN 'Sangat Baik'
            WHEN a.ipk >= 3.00 THEN 'Baik'
            WHEN a.ipk >= 2.50 THEN 'Cukup'
            ELSE 'Perlu Pembinaan'
        END,

        '.'
    ) AS hasil

    FROM mahasiswa m
    JOIN akademik a ON m.nim = a.nim;
END //

DELIMITER ;

CALL bagianC_krs();

-- =========================================
-- BAGIAN D: PERBANDINGAN
-- =========================================
DELIMITER //

DROP PROCEDURE IF EXISTS bagianD_perbandingan //

CREATE PROCEDURE bagianD_perbandingan()
BEGIN

    -- tampilkan data
    SELECT 
        m.nama,
        m.nim,
        m.semester,
        a.sks,
        a.ipk,
        a.status_pembayaran
    FROM mahasiswa m
    JOIN akademik a ON m.nim = a.nim;

    -- kesimpulan
    SELECT 
    CASE 
        WHEN a1.ipk > a2.ipk THEN 
            CONCAT(m1.nama, ' memiliki performa akademik lebih baik dibanding ', m2.nama)

        WHEN a2.ipk > a1.ipk THEN 
            CONCAT(m2.nama, ' memiliki performa akademik lebih baik dibanding ', m1.nama)

        ELSE
            CASE 
                WHEN a1.sks > a2.sks THEN 
                    CONCAT(m1.nama, ' lebih baik karena jumlah SKS lebih tinggi')
                WHEN a2.sks > a1.sks THEN 
                    CONCAT(m2.nama, ' lebih baik karena jumlah SKS lebih tinggi')
                ELSE 
                    'Kedua mahasiswa memiliki performa akademik yang sama'
            END
    END AS kesimpulan

    FROM mahasiswa m1
    JOIN akademik a1 ON m1.nim = a1.nim,
         mahasiswa m2
    JOIN akademik a2 ON m2.nim = a2.nim

    WHERE m1.nim = 'IK2411028'
      AND m2.nim = 'IK2411012';

END //

DELIMITER ;

CALL bagianD_perbandingan();

-- =========================================
-- SKENARIO UJI
-- =========================================

-- VALID
UPDATE akademik 
SET sks = 16, ipk = 3.20, status_pembayaran = 'LUNAS'
WHERE nim = 'IK2411028';
CALL bagianC_krs();

-- TIDAK VALID (BELUM BAYAR)
UPDATE akademik 
SET status_pembayaran = 'BELUM'
WHERE nim = 'IK2411028';
CALL bagianC_krs();

-- TIDAK VALID (SKS 0)
UPDATE akademik 
SET sks = 0, status_pembayaran = 'LUNAS'
WHERE nim = 'IK2411028';
CALL bagianC_krs();