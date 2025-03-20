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
-- Table structure for table `chat`
--

DROP TABLE IF EXISTS `chat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chat` (
  `chat_id` int NOT NULL AUTO_INCREMENT,
  `sender_id` int DEFAULT NULL,
  `sender_type` varchar(100) DEFAULT NULL,
  `receiver_id` int DEFAULT NULL,
  `receiver_type` varchar(100) DEFAULT NULL,
  `message` varchar(1000) DEFAULT NULL,
  `date_time` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`chat_id`)
) ENGINE=MyISAM AUTO_INCREMENT=15 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat`
--

LOCK TABLES `chat` WRITE;
/*!40000 ALTER TABLE `chat` DISABLE KEYS */;
INSERT INTO `chat` VALUES (1,2,'daycare',9,'parent','hello','2025-03-02 16:58:32'),(2,2,'daycare',9,'parent','baby','2025-03-02 16:58:36'),(3,9,'parent',2,'daycare','hello message seen','2025-03-02 16:57:47'),(4,2,'daycare',9,'parent','baby','2025-03-02 16:59:25'),(5,9,'parent',2,'daycare','hey','2025-03-02 17:01:54'),(6,9,'parent',2,'daycare','are you okay','2025-03-02 17:01:54'),(7,2,'daycare',9,'parent','baby','2025-03-02 17:02:45'),(8,2,'daycare',9,'parent','baby','2025-03-02 17:04:41'),(9,2,'daycare',9,'parent','okay','2025-03-02 17:05:14'),(10,9,'parent',2,'daycare','yo','2025-03-03 21:26:52'),(11,9,'parent',2,'daycare','Hii','2025-03-08 13:08:37'),(12,9,'parent',14,'daycare','hey','2025-03-08 14:46:05'),(13,8,'daycare',9,'parent','hello','2025-03-13 18:37:18'),(14,14,'daycare',9,'parent','hello\r\nhow r u?','2025-03-13 19:22:39');
/*!40000 ALTER TABLE `chat` ENABLE KEYS */;
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
