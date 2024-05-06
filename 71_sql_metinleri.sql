-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema apartman_sitesi
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema apartman_sitesi
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `apartman_sitesi` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `apartman_sitesi` ;

-- -----------------------------------------------------
-- Table `apartman_sitesi`.`Daireler`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `apartman_sitesi`.`Daireler` (
  `DaireNo` INT NOT NULL AUTO_INCREMENT,
  `Blok` VARCHAR(2) NOT NULL,
  `Kat` INT NOT NULL,
  `KapiNo` INT NOT NULL,
  `Alan` DECIMAL(5,2) NOT NULL,
  `SahibiAdiSoyadi` VARCHAR(100) NOT NULL,
  `SahibiIletisimBilgileri` VARCHAR(255) NULL DEFAULT NULL,
  `KiraciAdiSoyadi` VARCHAR(100) NULL DEFAULT NULL,
  `KiraciIletisimBilgileri` VARCHAR(255) NULL DEFAULT NULL,
  PRIMARY KEY (`DaireNo`))
ENGINE = InnoDB
AUTO_INCREMENT = 129
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `apartman_sitesi`.`Aidatlar`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `apartman_sitesi`.`Aidatlar` (
  `AidatID` INT NOT NULL AUTO_INCREMENT,
  `AidatAyi` VARCHAR(20) NULL DEFAULT NULL,
  `Tutar` DECIMAL(10,2) NULL DEFAULT NULL,
  `OdemeDurumu` ENUM('Ödenmedi', 'Ödendi') NULL DEFAULT NULL,
  `DaireNo` INT NULL DEFAULT NULL,
  PRIMARY KEY (`AidatID`),
  INDEX `DaireNo` (`DaireNo` ASC) VISIBLE,
  CONSTRAINT `aidatlar_ibfk_1`
    FOREIGN KEY (`DaireNo`)
    REFERENCES `apartman_sitesi`.`Daireler` (`DaireNo`))
ENGINE = InnoDB
AUTO_INCREMENT = 6
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `apartman_sitesi`.`Yoneticiler`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `apartman_sitesi`.`Yoneticiler` (
  `YoneticiID` INT NOT NULL AUTO_INCREMENT,
  `KullaniciAdi` VARCHAR(50) NOT NULL,
  `Sifre` VARCHAR(255) NOT NULL,
  `AdiSoyadi` VARCHAR(100) NOT NULL,
  `EpostaAdresi` VARCHAR(100) NOT NULL,
  `TelefonNumarasi` VARCHAR(20) NOT NULL,
  `DaireNo` INT NOT NULL,
  PRIMARY KEY (`YoneticiID`),
  UNIQUE INDEX `KullaniciAdi` (`KullaniciAdi` ASC) VISIBLE,
  UNIQUE INDEX `EpostaAdresi` (`EpostaAdresi` ASC) VISIBLE,
  INDEX `DaireNo` (`DaireNo` ASC) VISIBLE,
  CONSTRAINT `yoneticiler_ibfk_1`
    FOREIGN KEY (`DaireNo`)
    REFERENCES `apartman_sitesi`.`Daireler` (`DaireNo`))
ENGINE = InnoDB
AUTO_INCREMENT = 3
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `apartman_sitesi`.`Duyurular`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `apartman_sitesi`.`Duyurular` (
  `DuyuruID` INT NOT NULL AUTO_INCREMENT,
  `DuyuruBasligi` VARCHAR(255) NOT NULL,
  `DuyuruMetni` TEXT NOT NULL,
  `YayinlanmaTarihi` DATE NOT NULL,
  `Yoneticiler_YoneticiID` INT NOT NULL,
  PRIMARY KEY (`DuyuruID`, `Yoneticiler_YoneticiID`),
  INDEX `fk_Duyurular_Yoneticiler1_idx` (`Yoneticiler_YoneticiID` ASC) VISIBLE,
  CONSTRAINT `fk_Duyurular_Yoneticiler1`
    FOREIGN KEY (`Yoneticiler_YoneticiID`)
    REFERENCES `apartman_sitesi`.`Yoneticiler` (`YoneticiID`))
ENGINE = InnoDB
AUTO_INCREMENT = 2
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `apartman_sitesi`.`Giderler`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `apartman_sitesi`.`Giderler` (
  `GiderID` INT NOT NULL AUTO_INCREMENT,
  `GiderTuru` VARCHAR(50) NOT NULL,
  `Tutar` DECIMAL(10,2) NOT NULL,
  `Tarih` DATE NOT NULL,
  `Aciklama` TEXT NULL DEFAULT NULL,
  `DaireNo` INT NULL DEFAULT NULL,
  PRIMARY KEY (`GiderID`),
  INDEX `DaireNo` (`DaireNo` ASC) VISIBLE,
  CONSTRAINT `giderler_ibfk_1`
    FOREIGN KEY (`DaireNo`)
    REFERENCES `apartman_sitesi`.`Daireler` (`DaireNo`))
ENGINE = InnoDB
AUTO_INCREMENT = 5
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `apartman_sitesi`.`Kullanicilar`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `apartman_sitesi`.`Kullanicilar` (
  `KullaniciID` INT NOT NULL AUTO_INCREMENT,
  `KullaniciAdi` VARCHAR(50) NOT NULL,
  `Sifre` VARCHAR(255) NOT NULL,
  `YetkiSeviyesi` ENUM('Yonetici', 'Sakin') NOT NULL,
  `AdiSoyadi` VARCHAR(100) NOT NULL,
  `EpostaAdresi` VARCHAR(100) NOT NULL,
  `DaireNo` INT NULL DEFAULT NULL,
  PRIMARY KEY (`KullaniciID`),
  UNIQUE INDEX `KullaniciAdi` (`KullaniciAdi` ASC) VISIBLE,
  UNIQUE INDEX `EpostaAdresi` (`EpostaAdresi` ASC) VISIBLE,
  INDEX `DaireNo` (`DaireNo` ASC) VISIBLE,
  CONSTRAINT `kullanicilar_ibfk_1`
    FOREIGN KEY (`DaireNo`)
    REFERENCES `apartman_sitesi`.`Daireler` (`DaireNo`))
ENGINE = InnoDB
AUTO_INCREMENT = 20
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

USE `apartman_sitesi`;

DELIMITER $$
USE `apartman_sitesi`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `apartman_sitesi`.`duyuru_eklendi_trigger`
AFTER INSERT ON `apartman_sitesi`.`Duyurular`
FOR EACH ROW
BEGIN 
    DECLARE eski_duyuru_metni VARCHAR(255); 
    
    -- Eski duyuru metnini al 
    SELECT DuyuruMetni INTO eski_duyuru_metni 
    FROM Duyurular 
    WHERE DuyuruID = (SELECT MAX(DuyuruID) FROM Duyurular); 
    
    -- Eski duyuruyu yeni bir yere ekle 
    INSERT INTO YeniDuyurular (DuyuruBasligi, DuyuruMetni, YayinlanmaTarihi, Yoneticiler_YoneticiID) 
    VALUES (NEW.DuyuruBasligi, eski_duyuru_metni, NOW(), NEW.Yoneticiler_YoneticiID); 
END$$


DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
