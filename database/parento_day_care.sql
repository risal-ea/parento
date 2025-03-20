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
-- Table structure for table `day_care`
--

DROP TABLE IF EXISTS `day_care`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `day_care` (
  `day_care_id` int NOT NULL AUTO_INCREMENT,
  `login_id` int DEFAULT NULL,
  `day_care_name` varchar(100) DEFAULT NULL,
  `owner_name` varchar(100) DEFAULT NULL,
  `phone` varchar(100) DEFAULT NULL,
  `adress` varchar(100) DEFAULT NULL,
  `license_number` varchar(100) DEFAULT NULL,
  `capacity` varchar(100) DEFAULT NULL,
  `operating_time` varchar(100) DEFAULT NULL,
  `daycare_discription` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`day_care_id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `day_care`
--

LOCK TABLES `day_care` WRITE;
/*!40000 ALTER TABLE `day_care` DISABLE KEYS */;
INSERT INTO `day_care` VALUES (1,2,'baby care','ibru','2435436754','mullakkal(H)','lc65435654','40','7:00','super'),(2,4,'sula house','salah','5647365879','abc','l475647','35','7:40','wow'),(3,14,'amin daycare','amin','6282777268','valayamkulam','1234567890','18','34','good'),(4,22,'Care Land','messi','7456837567','Dubai,UAE','LC4534564','200','14H','best option');
/*!40000 ALTER TABLE `day_care` ENABLE KEYS */;
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
