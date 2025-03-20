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
-- Table structure for table `babies`
--

DROP TABLE IF EXISTS `babies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `babies` (
  `baby_id` int NOT NULL AUTO_INCREMENT,
  `parent_id` int DEFAULT NULL,
  `baby_name` varchar(100) DEFAULT NULL,
  `baby_dob` varchar(100) DEFAULT NULL,
  `baby_gender` varchar(100) DEFAULT NULL,
  `baby_photo` varchar(100) DEFAULT NULL,
  `allergies_or_dietry_restriction` varchar(100) DEFAULT NULL,
  `medical_condition` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`baby_id`)
) ENGINE=MyISAM AUTO_INCREMENT=15 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `babies`
--

LOCK TABLES `babies` WRITE;
/*!40000 ALTER TABLE `babies` DISABLE KEYS */;
INSERT INTO `babies` VALUES (1,1,'kutus','20/3/2030','male',NULL,'null','good'),(2,3,'vava','1/3/2030','male',NULL,'null','good'),(11,7,'achu','2025-03-03','Male','null','noo','good'),(12,3,'ammu','2025-03-02','Female','null','none','good'),(10,3,'arya','2/3/2025','female','','good','good'),(13,3,'sree','2025-03-02','Female','null','none','good'),(14,3,'rono','2025-03-03','Male','static/baby_photos/scaled_1000255890.jpg','none','good');
/*!40000 ALTER TABLE `babies` ENABLE KEYS */;
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
