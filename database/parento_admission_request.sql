-- MySQL dump 10.13  Distrib 8.0.38, for macos14 (x86_64)
--
-- Host: 127.0.0.1    Database: parento
-- ------------------------------------------------------
-- Server version	9.0.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `admission_request`
--

DROP TABLE IF EXISTS `admission_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admission_request` (
  `adminssion_id` int NOT NULL AUTO_INCREMENT,
  `parent_id` int DEFAULT NULL,
  `baby_id` int DEFAULT NULL,
  `start_date` varchar(100) DEFAULT NULL,
  `preferred_schedule` varchar(100) DEFAULT NULL,
  `qr_code` varchar(100) DEFAULT NULL,
  `daycare_id` int DEFAULT NULL,
  `payment` varchar(45) DEFAULT NULL,
  `date_time` varchar(45) DEFAULT NULL,
  `payment_status` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`adminssion_id`)
) ENGINE=MyISAM AUTO_INCREMENT=23 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admission_request`
--

LOCK TABLES `admission_request` WRITE;
/*!40000 ALTER TABLE `admission_request` DISABLE KEYS */;
INSERT INTO `admission_request` VALUES (2,3,1,'12/2/2025','11:20','static/qr/2.png',1,'2000','2025-03-04 10:59:26','pending'),(3,3,1,'12/4/2025','11:30','static/qr/3.png',3,'20000','2025-03-08 13:08:37','pending'),(4,3,1,'04/04/2025','all day','static/qr/4.png',1,'3000','2025-03-08 13:16:09','pending'),(22,3,12,'2/4/2025','4:50','static/qr/22.png',3,'40000','2025-03-08 14:46:05','paid');
/*!40000 ALTER TABLE `admission_request` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-03-14  2:03:59
