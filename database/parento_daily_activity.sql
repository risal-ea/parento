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
-- Table structure for table `daily_activity`
--

DROP TABLE IF EXISTS `daily_activity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `daily_activity` (
  `activity_id` int NOT NULL AUTO_INCREMENT,
  `baby_id` int DEFAULT NULL,
  `date` varchar(100) DEFAULT NULL,
  `activity_type` varchar(100) DEFAULT NULL,
  `description` varchar(1000) DEFAULT NULL,
  `start_time` varchar(100) DEFAULT NULL,
  `end_time` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`activity_id`)
) ENGINE=MyISAM AUTO_INCREMENT=14 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `daily_activity`
--

LOCK TABLES `daily_activity` WRITE;
/*!40000 ALTER TABLE `daily_activity` DISABLE KEYS */;
INSERT INTO `daily_activity` VALUES (1,1,'2025-02-16','Sleeping','Night sleep','22:00','06:00'),(2,1,'2025-02-16','Playing','Outdoor games in the park','17:00','18:00'),(3,1,'2025-02-16','Studying','Math and reading practice','10:00','12:00'),(4,1,'2025-02-16','Eating','Breakfast (milk & cereal)','08:00','08:30'),(5,2,'2025-02-16','Sleeping','Afternoon nap','14:00','16:00'),(6,2,'2025-02-16','Playing','Board games with friends','18:30','19:00'),(7,2,'2025-02-16','Studying','Science revision','15:00','16:30'),(8,2,'2025-02-16','Eating','Lunch (rice & vegetables)','12:30','13:00'),(9,1,'2025-02-20','Outdoor Activity','football match','16:28','18:28'),(10,1,'2025-03-05','Studying','Computer Science ','02:00','02:13'),(11,2,'2025-03-05','Playing','Basket ball','01:06','02:06'),(12,2,'2025-03-06','Sleeping','rest','01:14','01:16'),(13,14,'2025-03-14','Outdoor Activity','playing hide and seek ','19:16','20:14');
/*!40000 ALTER TABLE `daily_activity` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-03-14  2:04:00
