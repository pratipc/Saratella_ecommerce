CREATE DATABASE  IF NOT EXISTS `ecommerce_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `ecommerce_db`;
-- MySQL dump 10.13  Distrib 8.0.42, for Win64 (x86_64)
--
-- Host: localhost    Database: ecommerce_db
-- ------------------------------------------------------
-- Server version	8.0.42

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
-- Table structure for table `areas`
--

DROP TABLE IF EXISTS `areas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `areas` (
  `area_id` int NOT NULL AUTO_INCREMENT,
  `region_id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  `code` varchar(20) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`area_id`),
  KEY `fk_area_region` (`region_id`),
  CONSTRAINT `fk_area_region` FOREIGN KEY (`region_id`) REFERENCES `regions` (`region_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `areas`
--

LOCK TABLES `areas` WRITE;
/*!40000 ALTER TABLE `areas` DISABLE KEYS */;
INSERT INTO `areas` VALUES (1,1,'New York Tri-State','US-NY-TRI',1),(2,2,'California','US-CA',1),(3,3,'Texas','US-TX',1);
/*!40000 ALTER TABLE `areas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attribute_values`
--

DROP TABLE IF EXISTS `attribute_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attribute_values` (
  `value_id` int NOT NULL AUTO_INCREMENT,
  `attribute_id` int NOT NULL,
  `value` varchar(50) NOT NULL,
  `color_code` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`value_id`),
  KEY `attribute_id` (`attribute_id`),
  CONSTRAINT `attribute_values_ibfk_1` FOREIGN KEY (`attribute_id`) REFERENCES `attributes` (`attribute_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attribute_values`
--

LOCK TABLES `attribute_values` WRITE;
/*!40000 ALTER TABLE `attribute_values` DISABLE KEYS */;
/*!40000 ALTER TABLE `attribute_values` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attributes`
--

DROP TABLE IF EXISTS `attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attributes` (
  `attribute_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`attribute_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attributes`
--

LOCK TABLES `attributes` WRITE;
/*!40000 ALTER TABLE `attributes` DISABLE KEYS */;
/*!40000 ALTER TABLE `attributes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `backorders`
--

DROP TABLE IF EXISTS `backorders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `backorders` (
  `backorder_id` bigint NOT NULL AUTO_INCREMENT,
  `store_id` int NOT NULL,
  `original_order_id` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  `variant_id` bigint DEFAULT NULL,
  `quantity` int NOT NULL,
  `status` enum('pending','released','cancelled') DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`backorder_id`),
  KEY `store_id` (`store_id`),
  KEY `original_order_id` (`original_order_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `backorders_ibfk_1` FOREIGN KEY (`store_id`) REFERENCES `stores` (`store_id`),
  CONSTRAINT `backorders_ibfk_2` FOREIGN KEY (`original_order_id`) REFERENCES `orders` (`order_id`),
  CONSTRAINT `backorders_ibfk_3` FOREIGN KEY (`product_id`) REFERENCES `sku_master` (`sku_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `backorders`
--

LOCK TABLES `backorders` WRITE;
/*!40000 ALTER TABLE `backorders` DISABLE KEYS */;
INSERT INTO `backorders` VALUES (1,1,12,3,1,4,'released','2026-03-11 17:30:40','2026-03-11 20:59:53'),(2,1,1,3,2,1,'pending','2026-04-07 11:48:10','2026-04-07 11:48:10');
/*!40000 ALTER TABLE `backorders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `brands`
--

DROP TABLE IF EXISTS `brands`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `brands` (
  `brand_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text,
  `logo_url` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`brand_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `brands`
--

LOCK TABLES `brands` WRITE;
/*!40000 ALTER TABLE `brands` DISABLE KEYS */;
INSERT INTO `brands` VALUES (1,'TechPro','High end electronics',NULL,NULL,'2026-02-19 19:01:37'),(2,'OfficeMate','Reliable supplies',NULL,NULL,'2026-02-19 19:01:37'),(3,'ErgoLife','Ergonomic furniture',NULL,NULL,'2026-02-19 19:01:37'),(4,'Vollrath','',NULL,NULL,'2026-03-19 22:42:58'),(5,'Global Industrial','',NULL,NULL,'2026-03-20 22:29:13'),(6,'EcoClean Pro','',NULL,NULL,'2026-03-23 21:45:24'),(7,'CafeBrand',NULL,NULL,NULL,'2026-04-13 20:33:20');
/*!40000 ALTER TABLE `brands` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cart_items`
--

DROP TABLE IF EXISTS `cart_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cart_items` (
  `cart_item_id` bigint NOT NULL AUTO_INCREMENT,
  `cart_id` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  `quantity` int NOT NULL DEFAULT '1',
  `price` decimal(10,2) NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `variant_id` bigint DEFAULT NULL,
  PRIMARY KEY (`cart_item_id`),
  UNIQUE KEY `uk_cart_product_variant` (`cart_id`,`product_id`,`variant_id`),
  KEY `fk_cart_item_sku_variant` (`variant_id`),
  CONSTRAINT `fk_cart_item_sku_variant` FOREIGN KEY (`variant_id`) REFERENCES `sku_variant` (`variant_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=179 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart_items`
--

LOCK TABLES `cart_items` WRITE;
/*!40000 ALTER TABLE `cart_items` DISABLE KEYS */;
INSERT INTO `cart_items` VALUES (1,1,1,20,1200.00,'2026-02-20 17:59:43','2026-02-20 18:02:33',NULL),(19,3,4,10,450.00,'2026-02-24 01:32:03','2026-02-24 01:53:04',3),(20,3,4,2,550.00,'2026-02-24 01:32:07','2026-02-24 01:53:08',4),(21,7,3,4,250.00,'2026-02-24 01:59:13','2026-02-24 01:59:20',1),(22,7,3,2,260.00,'2026-02-24 01:59:16','2026-02-24 01:59:17',2),(23,7,4,3,450.00,'2026-02-24 01:59:23','2026-02-24 01:59:25',3),(24,7,4,1,550.00,'2026-02-24 01:59:27','2026-02-24 01:59:27',4),(25,8,1,10,1200.00,'2026-02-24 02:01:39','2026-02-24 02:01:56',NULL),(34,11,2,1,350.00,'2026-02-25 03:09:19','2026-02-25 03:09:19',NULL),(38,12,2,1,350.00,'2026-02-25 22:12:25','2026-02-25 22:12:25',NULL),(39,12,3,1,250.00,'2026-02-25 22:12:28','2026-02-25 22:12:28',1),(40,9,2,2,350.00,'2026-02-27 13:18:53','2026-02-27 13:22:02',NULL),(41,9,3,1,250.00,'2026-02-27 13:19:35','2026-02-27 13:22:02',1),(42,14,2,2,350.00,'2026-02-27 13:39:29','2026-02-27 13:39:29',NULL),(43,14,3,3,250.00,'2026-02-27 13:39:29','2026-02-27 14:09:31',1),(44,14,1,1,1200.00,'2026-02-27 14:07:14','2026-02-27 14:09:31',NULL),(46,16,1,1,1200.00,'2026-02-27 14:12:33','2026-02-27 14:12:33',NULL),(47,16,2,1,350.00,'2026-02-27 14:12:33','2026-02-27 14:12:49',NULL),(48,16,3,2,250.00,'2026-02-27 14:12:33','2026-02-27 14:12:45',1),(53,17,2,1,350.00,'2026-02-28 18:25:08','2026-02-28 18:25:08',NULL),(54,17,1,1,1200.00,'2026-02-28 18:25:10','2026-02-28 18:25:10',NULL),(55,18,1,5,1200.00,'2026-03-01 03:41:29','2026-03-01 03:41:33',NULL),(56,19,5,2,45.00,'2026-03-04 21:31:40','2026-03-04 21:32:22',NULL),(57,19,3,1,250.00,'2026-03-04 21:31:46','2026-03-04 21:31:46',1),(58,19,3,5,260.00,'2026-03-04 21:31:48','2026-03-04 21:32:53',2),(59,19,4,5,450.00,'2026-03-04 21:31:59','2026-03-04 21:32:02',3),(60,19,4,1,550.00,'2026-03-04 21:32:14','2026-03-04 21:32:14',4),(61,20,2,1,350.00,'2026-03-06 18:37:09','2026-03-06 18:37:09',NULL),(62,20,3,4,250.00,'2026-03-06 18:37:15','2026-03-06 18:38:10',1),(63,21,2,1,350.00,'2026-03-06 18:39:10','2026-03-06 18:39:10',NULL),(64,21,3,4,250.00,'2026-03-06 18:39:10','2026-03-06 18:39:10',1),(68,22,5,1,45.00,'2026-03-07 17:37:32','2026-03-07 17:38:58',NULL),(69,22,1,3,1200.00,'2026-03-07 17:45:39','2026-03-07 17:45:43',NULL),(70,22,3,1,250.00,'2026-03-07 17:46:26','2026-03-07 17:46:26',1),(71,22,3,1,260.00,'2026-03-07 17:46:56','2026-03-07 17:46:56',2),(72,23,1,2,1200.00,'2026-03-07 18:06:03','2026-03-07 18:06:36',NULL),(73,23,5,2,45.00,'2026-03-07 18:06:09','2026-03-07 18:06:41',NULL),(74,23,2,1,350.00,'2026-03-07 18:06:12','2026-03-07 18:06:12',NULL),(75,23,3,2,250.00,'2026-03-07 18:06:15','2026-03-07 18:06:18',1),(76,23,3,1,260.00,'2026-03-07 18:06:17','2026-03-07 18:06:17',2),(77,24,2,2,350.00,'2026-03-11 15:25:09','2026-03-11 15:26:33',NULL),(78,24,1,2,1200.00,'2026-03-11 15:25:10','2026-03-11 15:26:35',NULL),(79,24,3,2,260.00,'2026-03-11 15:25:17','2026-03-11 15:26:27',2),(80,25,2,1,350.00,'2026-03-11 15:27:19','2026-03-11 15:27:19',NULL),(81,25,1,2,1200.00,'2026-03-11 15:27:20','2026-03-11 15:27:23',NULL),(82,25,3,3,260.00,'2026-03-11 15:27:26','2026-03-11 15:27:27',2),(83,26,2,5,350.00,'2026-03-11 22:27:26','2026-03-11 22:27:33',NULL),(84,26,1,5,1200.00,'2026-03-11 22:27:27','2026-03-11 22:27:30',NULL),(85,27,1,1,1200.00,'2026-03-12 18:20:31','2026-03-12 18:20:31',NULL),(86,27,2,1,350.00,'2026-03-12 18:20:32','2026-03-12 18:20:32',NULL),(87,27,3,4,250.00,'2026-03-12 18:20:54','2026-03-12 18:20:57',1),(96,28,3,5,250.00,'2026-03-14 20:28:26','2026-03-14 20:31:14',1),(101,31,23,5,45.00,'2026-03-24 03:11:19','2026-03-24 03:11:32',54),(103,32,23,2,45.00,'2026-03-24 15:19:37','2026-03-24 15:19:43',54),(104,32,23,2,48.00,'2026-03-24 15:19:48','2026-03-24 15:19:48',55),(105,33,3,1,250.00,'2026-03-27 17:42:57','2026-03-27 17:42:57',1),(106,33,2,1,350.00,'2026-03-27 17:43:08','2026-03-27 17:43:08',NULL),(107,33,5,1,45.00,'2026-03-27 17:43:11','2026-03-27 17:43:11',NULL),(108,33,23,2,45.00,'2026-03-27 17:43:23','2026-03-27 17:43:23',54),(109,33,23,2,48.00,'2026-03-27 17:43:25','2026-03-27 17:43:25',55),(110,33,23,2,46.00,'2026-03-27 17:43:26','2026-03-27 17:43:26',56),(111,34,1,4,1200.00,'2026-03-27 18:37:05','2026-03-27 18:37:07',NULL),(112,34,2,5,350.00,'2026-03-27 18:37:05','2026-03-27 18:37:09',NULL),(114,35,2,2,350.00,'2026-03-27 18:39:31','2026-03-27 18:39:32',NULL),(115,36,2,4,350.00,'2026-03-27 18:39:48','2026-03-27 18:39:51',NULL),(116,37,2,4,350.00,'2026-03-27 18:41:57','2026-03-27 18:41:59',NULL),(117,38,1,2,1200.00,'2026-03-27 20:00:10','2026-03-27 20:00:13',NULL),(118,38,2,2,350.00,'2026-03-27 20:00:11','2026-03-27 20:00:14',NULL),(119,38,5,1,45.00,'2026-03-27 20:00:18','2026-03-27 20:00:18',NULL),(120,38,21,1,300.00,'2026-03-27 20:00:24','2026-03-27 20:00:24',51),(121,38,21,1,300.00,'2026-03-27 20:00:26','2026-03-27 20:00:26',52),(122,38,21,1,300.00,'2026-03-27 20:00:28','2026-03-27 20:00:28',53),(123,39,1,6,1200.00,'2026-03-27 23:23:17','2026-03-27 23:23:20',NULL),(124,39,2,6,350.00,'2026-03-27 23:23:21','2026-03-27 23:23:22',NULL),(126,40,1,4,1200.00,'2026-04-01 02:04:12','2026-04-01 02:49:10',NULL),(127,40,3,4,250.00,'2026-04-01 02:04:17','2026-04-01 02:04:19',1),(129,42,1,1,1200.00,'2026-04-02 17:02:06','2026-04-02 17:02:06',NULL),(130,42,2,1,350.00,'2026-04-02 17:02:09','2026-04-02 17:02:09',NULL),(131,42,3,1,250.00,'2026-04-02 17:02:19','2026-04-02 17:02:19',1),(132,42,23,2,46.00,'2026-04-02 17:02:31','2026-04-02 17:02:31',56),(133,43,1,1,1200.00,'2026-04-03 02:24:13','2026-04-03 02:24:13',NULL),(134,43,23,3,45.00,'2026-04-03 02:24:18','2026-04-03 02:24:34',54),(135,43,2,1,350.00,'2026-04-03 02:24:42','2026-04-03 02:24:42',NULL),(136,43,3,1,250.00,'2026-04-03 02:24:45','2026-04-03 02:24:45',1),(137,43,3,1,260.00,'2026-04-03 02:24:46','2026-04-03 02:24:46',2),(141,44,23,2,45.00,'2026-04-03 02:31:20','2026-04-03 02:36:15',54),(143,45,1,1,1200.00,'2026-04-03 18:04:12','2026-04-03 18:04:12',NULL),(144,45,2,1,350.00,'2026-04-03 18:04:12','2026-04-03 18:04:12',NULL),(145,45,3,1,250.00,'2026-04-03 18:04:12','2026-04-03 18:04:12',1),(146,45,3,1,260.00,'2026-04-03 18:04:12','2026-04-03 18:04:12',2),(147,45,23,3,45.00,'2026-04-03 18:04:12','2026-04-03 18:04:12',54),(151,45,29,13,20.00,'2026-04-03 19:24:20','2026-04-03 20:08:41',NULL),(152,46,1,1,1200.00,'2026-04-04 18:18:45','2026-04-04 18:18:45',NULL),(153,46,2,1,350.00,'2026-04-04 18:18:46','2026-04-04 18:18:46',NULL),(154,46,27,1,20.00,'2026-04-04 18:18:50','2026-04-04 18:18:50',NULL),(155,46,28,1,2.00,'2026-04-04 18:18:51','2026-04-04 18:18:51',NULL),(156,46,29,1,200.00,'2026-04-04 18:18:53','2026-04-04 18:18:53',NULL),(157,47,30,1,22.00,'2026-04-07 13:57:41','2026-04-07 13:57:41',NULL),(158,48,1,2,1200.00,'2026-04-07 17:03:49','2026-04-07 17:03:51',NULL),(159,48,2,2,350.00,'2026-04-07 17:03:51','2026-04-07 17:03:52',NULL),(160,48,3,3,250.00,'2026-04-07 17:03:56','2026-04-07 17:03:57',1),(161,49,1,1,1200.00,'2026-04-07 18:39:47','2026-04-07 18:39:47',NULL),(162,49,2,1,350.00,'2026-04-07 18:39:49','2026-04-07 18:39:49',NULL),(163,49,23,4,48.00,'2026-04-07 18:39:59','2026-04-07 18:40:01',55),(167,51,26,1,122.00,'2026-04-09 18:06:04','2026-04-09 18:06:04',NULL),(168,51,23,4,46.00,'2026-04-09 18:06:11','2026-04-09 18:06:13',56),(169,52,2,2,350.00,'2026-04-09 21:45:29','2026-04-09 21:45:30',NULL),(170,52,1,2,1200.00,'2026-04-09 21:45:31','2026-04-09 21:45:33',NULL),(172,52,23,11,45.00,'2026-04-09 22:00:42','2026-04-09 22:00:49',54),(173,53,23,2,46.00,'2026-04-16 20:48:18','2026-04-16 20:48:18',56),(174,53,23,3,48.00,'2026-04-16 20:48:23','2026-04-16 21:21:16',55),(175,53,23,2,45.00,'2026-04-16 20:48:24','2026-04-16 20:48:24',54),(176,54,23,10,46.00,'2026-04-17 19:56:25','2026-04-17 19:56:30',56),(177,55,2,8,350.00,'2026-04-17 20:08:17','2026-04-17 20:08:21',NULL),(178,50,1,1,1200.00,'2026-04-24 21:44:58','2026-04-24 21:44:58',NULL);
/*!40000 ALTER TABLE `cart_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `carts`
--

DROP TABLE IF EXISTS `carts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `carts` (
  `cart_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint DEFAULT NULL,
  `session_id` varchar(255) DEFAULT NULL,
  `status` enum('active','converted','abandoned') NOT NULL DEFAULT 'active',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `store_id` int DEFAULT NULL,
  PRIMARY KEY (`cart_id`),
  KEY `user_id` (`user_id`),
  KEY `fk_cart_store` (`store_id`),
  CONSTRAINT `carts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_cart_store` FOREIGN KEY (`store_id`) REFERENCES `stores` (`store_id`)
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `carts`
--

LOCK TABLES `carts` WRITE;
/*!40000 ALTER TABLE `carts` DISABLE KEYS */;
INSERT INTO `carts` VALUES (1,NULL,'9e905d90-8a41-4ec8-9e92-9d7e03c453f6','active','2026-02-20 17:59:43','2026-02-20 17:59:43',2),(2,1,NULL,'converted','2026-02-23 16:15:14','2026-02-24 01:54:41',1),(3,1,NULL,'converted','2026-02-23 21:13:58','2026-02-24 01:58:52',3),(5,1,NULL,'converted','2026-02-23 22:19:08','2026-02-24 01:59:40',4),(6,1,NULL,'converted','2026-02-23 22:38:47','2026-02-24 02:01:13',2),(7,1,NULL,'converted','2026-02-24 01:59:13','2026-02-24 02:01:13',3),(8,1,NULL,'converted','2026-02-24 02:01:39','2026-02-24 02:02:24',3),(9,1,NULL,'converted','2026-02-24 02:15:00','2026-02-27 13:25:53',3),(11,1,NULL,'abandoned','2026-02-24 18:24:28','2026-02-25 19:28:58',1),(12,1,NULL,'abandoned','2026-02-25 22:11:10','2026-02-27 13:26:30',1),(14,1,NULL,'converted','2026-02-27 13:26:30','2026-02-27 14:10:32',3),(16,1,NULL,'converted','2026-02-27 14:12:33','2026-02-27 14:12:56',3),(17,1,NULL,'converted','2026-02-27 16:42:38','2026-02-28 18:25:15',1),(18,1,NULL,'converted','2026-03-01 03:41:29','2026-03-01 03:41:38',1),(19,1,NULL,'converted','2026-03-04 21:31:40','2026-03-04 21:33:26',1),(20,1,NULL,'converted','2026-03-06 18:37:09','2026-03-06 18:38:35',1),(21,1,NULL,'converted','2026-03-06 18:39:10','2026-03-06 18:39:31',1),(22,1,NULL,'converted','2026-03-07 17:37:09','2026-03-07 17:47:13',1),(23,1,NULL,'converted','2026-03-07 18:06:03','2026-03-07 18:06:50',1),(24,1,NULL,'converted','2026-03-11 15:25:09','2026-03-11 15:26:48',1),(25,1,NULL,'converted','2026-03-11 15:27:19','2026-03-11 15:27:39',3),(26,1,NULL,'converted','2026-03-11 22:27:26','2026-03-11 22:27:47',1),(27,1,NULL,'converted','2026-03-12 18:20:31','2026-03-12 18:22:53',1),(28,1,NULL,'converted','2026-03-14 15:08:55','2026-03-14 20:33:58',1),(29,NULL,'40c92e99-cf94-4021-a6fc-0aa439cb2e4a','active','2026-03-18 02:34:21','2026-03-18 02:34:21',1),(30,NULL,'83a7344d-4122-4fd7-87ad-e37e3ab5e190','active','2026-03-21 03:14:09','2026-03-21 03:14:09',1),(31,NULL,'011c2241-2509-404c-87ff-014f8acb2a93','active','2026-03-24 03:11:19','2026-03-24 03:11:19',1),(32,1,NULL,'converted','2026-03-24 15:19:02','2026-03-31 20:55:01',1),(33,12,NULL,'converted','2026-03-27 17:42:57','2026-03-27 18:36:29',1),(34,12,NULL,'converted','2026-03-27 18:37:05','2026-03-27 18:37:22',1),(35,12,NULL,'converted','2026-03-27 18:39:25','2026-03-27 18:39:40',1),(36,12,NULL,'converted','2026-03-27 18:39:48','2026-03-27 18:40:02',1),(37,13,NULL,'converted','2026-03-27 18:41:57','2026-03-27 18:42:36',1),(38,14,NULL,'converted','2026-03-27 20:00:10','2026-03-27 20:02:15',1),(39,14,NULL,'converted','2026-03-27 23:23:17','2026-03-27 23:23:35',1),(40,1,NULL,'converted','2026-03-31 22:52:58','2026-04-01 02:49:33',1),(42,1,NULL,'converted','2026-04-02 17:02:06','2026-04-02 17:17:50',NULL),(43,1,NULL,'converted','2026-04-03 02:24:13','2026-04-03 02:25:16',NULL),(44,1,NULL,'converted','2026-04-03 02:31:10','2026-04-03 02:38:42',NULL),(45,1,NULL,'converted','2026-04-03 18:03:02','2026-04-04 03:00:51',NULL),(46,1,NULL,'converted','2026-04-04 18:18:45','2026-04-04 18:29:37',NULL),(47,1,NULL,'converted','2026-04-07 13:57:41','2026-04-07 13:58:02',NULL),(48,12,NULL,'converted','2026-04-07 17:03:49','2026-04-07 17:04:09',NULL),(49,12,NULL,'converted','2026-04-07 18:39:47','2026-04-07 18:40:11',NULL),(50,10,NULL,'active','2026-04-08 18:33:36','2026-04-08 21:44:13',NULL),(51,1,NULL,'converted','2026-04-08 22:19:07','2026-04-09 18:06:18',NULL),(52,12,NULL,'converted','2026-04-09 21:45:29','2026-04-09 22:31:18',NULL),(53,12,NULL,'converted','2026-04-16 20:48:18','2026-04-17 19:55:52',NULL),(54,12,NULL,'converted','2026-04-17 19:56:25','2026-04-17 19:57:28',NULL),(55,12,NULL,'converted','2026-04-17 20:08:17','2026-04-17 20:08:38',NULL);
/*!40000 ALTER TABLE `carts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `parent_id` int DEFAULT NULL,
  `description` text,
  `image_url` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`category_id`),
  KEY `fk_category_parent` (`parent_id`),
  CONSTRAINT `fk_category_parent` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`category_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,'Electronics',NULL,'Gadgets and devices',NULL,'2026-02-19 19:01:37'),(2,'Office Supplies',NULL,'Essentials for business',NULL,'2026-02-19 19:01:37'),(3,'Furniture',NULL,'Office furniture and decor',NULL,'2026-02-19 19:01:37'),(4,'Kitchen Eq',NULL,'Kitchen Appliances & equipment seller',NULL,'2026-03-19 22:42:01'),(5,'warehouse equipment',NULL,'',NULL,'2026-03-20 22:28:50'),(6,'Janitorial Supplies',NULL,'',NULL,'2026-03-23 21:45:01'),(7,'Beverages',NULL,'','/static/uploads/categories/1777045035_oil_canola2.jpg','2026-04-13 20:33:19'),(8,'Apparel',NULL,'','/static/uploads/categories/1777044983_1000ml-Deftton-Rose-Hand-Sanitizer.jpg','2026-04-13 20:33:20');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fulfillment_items`
--

DROP TABLE IF EXISTS `fulfillment_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fulfillment_items` (
  `fulfillment_item_id` bigint NOT NULL AUTO_INCREMENT,
  `fulfillment_id` bigint NOT NULL,
  `order_item_id` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  `variant_id` bigint DEFAULT NULL,
  `quantity_picked` int NOT NULL,
  PRIMARY KEY (`fulfillment_item_id`),
  KEY `fulfillment_id` (`fulfillment_id`),
  KEY `order_item_id` (`order_item_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `fulfillment_items_ibfk_1` FOREIGN KEY (`fulfillment_id`) REFERENCES `order_fulfillments` (`fulfillment_id`) ON DELETE CASCADE,
  CONSTRAINT `fulfillment_items_ibfk_2` FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`order_item_id`),
  CONSTRAINT `fulfillment_items_ibfk_3` FOREIGN KEY (`product_id`) REFERENCES `sku_master` (`sku_id`)
) ENGINE=InnoDB AUTO_INCREMENT=85 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fulfillment_items`
--

LOCK TABLES `fulfillment_items` WRITE;
/*!40000 ALTER TABLE `fulfillment_items` DISABLE KEYS */;
INSERT INTO `fulfillment_items` VALUES (1,1,25,3,1,1),(2,1,26,3,2,4),(3,1,27,4,3,4),(4,1,28,4,4,1),(5,1,29,5,NULL,1),(6,2,25,3,1,1),(7,2,26,3,2,5),(8,2,27,4,3,4),(9,2,28,4,4,1),(10,3,25,3,1,1),(11,3,26,3,2,5),(12,3,27,4,3,5),(13,3,28,4,4,1),(14,4,25,3,1,1),(15,4,26,3,2,5),(16,4,27,4,3,5),(17,4,28,4,4,1),(18,5,38,1,NULL,3),(19,5,39,3,1,1),(20,5,40,3,2,1),(21,6,45,1,NULL,2),(22,6,46,2,NULL,1),(23,6,47,3,1,2),(24,6,48,3,2,1),(25,7,32,2,NULL,1),(26,9,25,3,1,1),(27,9,26,3,2,5),(28,9,28,4,4,1),(29,9,29,5,NULL,2),(30,10,25,3,1,1),(31,10,26,3,2,5),(32,10,27,4,3,5),(33,10,28,4,4,1),(34,10,29,5,NULL,2),(35,11,35,2,NULL,1),(36,11,36,3,1,4),(37,12,38,1,NULL,3),(38,12,39,3,1,1),(39,12,40,3,2,1),(40,12,41,5,NULL,1),(41,13,45,1,NULL,2),(42,13,46,2,NULL,1),(43,13,47,3,1,2),(44,13,48,3,2,1),(45,13,49,5,NULL,2),(46,14,50,1,NULL,2),(47,14,51,2,NULL,2),(48,14,52,3,2,1),(49,15,60,1,NULL,1),(50,15,61,2,NULL,1),(51,15,62,3,1,4),(52,16,63,3,1,5),(53,1,12,3,2,1),(54,1,13,23,54,3),(55,1,14,29,NULL,13),(56,2,12,3,2,1),(57,2,13,23,54,3),(58,2,14,29,NULL,13),(59,3,12,3,2,1),(60,3,13,23,54,3),(61,3,14,29,NULL,13),(62,4,12,3,2,1),(63,4,13,23,54,3),(64,4,14,29,NULL,13),(65,5,12,3,2,1),(66,5,13,23,54,3),(67,5,14,29,NULL,13),(68,6,12,3,2,1),(69,6,13,23,54,3),(70,6,14,29,NULL,13),(71,7,12,3,2,1),(72,7,13,23,54,3),(73,7,14,29,NULL,13),(74,8,1,1,NULL,1),(75,8,2,2,NULL,1),(76,8,3,3,1,1),(77,8,5,23,54,3),(78,9,26,3,1,3),(79,10,29,23,55,4),(80,11,30,23,56,2),(81,11,31,26,NULL,1),(82,12,33,1,NULL,2),(83,12,34,2,NULL,1),(84,13,40,2,NULL,5);
/*!40000 ALTER TABLE `fulfillment_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `grouped_products`
--

DROP TABLE IF EXISTS `grouped_products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `grouped_products` (
  `group_id` bigint NOT NULL AUTO_INCREMENT,
  `parent_sku_id` bigint NOT NULL,
  `child_sku_id` bigint NOT NULL,
  `default_qty` int DEFAULT '1',
  PRIMARY KEY (`group_id`),
  KEY `parent_sku_id` (`parent_sku_id`),
  KEY `child_sku_id` (`child_sku_id`),
  CONSTRAINT `grouped_products_ibfk_1` FOREIGN KEY (`parent_sku_id`) REFERENCES `sku_master` (`sku_id`) ON DELETE CASCADE,
  CONSTRAINT `grouped_products_ibfk_2` FOREIGN KEY (`child_sku_id`) REFERENCES `sku_master` (`sku_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `grouped_products`
--

LOCK TABLES `grouped_products` WRITE;
/*!40000 ALTER TABLE `grouped_products` DISABLE KEYS */;
INSERT INTO `grouped_products` VALUES (1,1,2,1),(2,1,3,1);
/*!40000 ALTER TABLE `grouped_products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_exceptions`
--

DROP TABLE IF EXISTS `inventory_exceptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_exceptions` (
  `exception_id` bigint NOT NULL AUTO_INCREMENT,
  `store_id` int NOT NULL,
  `order_id` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  `variant_id` bigint DEFAULT NULL,
  `reported_by` bigint NOT NULL,
  `expected_qty` int NOT NULL,
  `actual_picked_qty` int NOT NULL,
  `status` enum('pending','resolved') NOT NULL DEFAULT 'pending',
  `inventory_action` varchar(50) DEFAULT NULL,
  `reason_code` varchar(50) DEFAULT NULL,
  `order_action` varchar(50) DEFAULT NULL,
  `manager_count` int DEFAULT NULL,
  `resolution_notes` text,
  `resolved_by` bigint DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`exception_id`),
  KEY `store_id` (`store_id`),
  KEY `order_id` (`order_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `inventory_exceptions_ibfk_1` FOREIGN KEY (`store_id`) REFERENCES `stores` (`store_id`),
  CONSTRAINT `inventory_exceptions_ibfk_2` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
  CONSTRAINT `inventory_exceptions_ibfk_3` FOREIGN KEY (`product_id`) REFERENCES `sku_master` (`sku_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_exceptions`
--

LOCK TABLES `inventory_exceptions` WRITE;
/*!40000 ALTER TABLE `inventory_exceptions` DISABLE KEYS */;
INSERT INTO `inventory_exceptions` VALUES (1,1,1,3,2,7,1,0,'resolved','Shrinkage Accepted','Damaged Stock','backorder',0,'',6,'2026-04-07 11:33:04','2026-04-07 11:48:10'),(2,1,6,1,NULL,7,2,0,'resolved','Shrinkage Accepted','Damaged Stock','cancel',0,'',6,'2026-04-07 11:51:59','2026-04-07 11:53:26'),(3,1,6,2,NULL,7,2,0,'resolved','Shrinkage Accepted','System Inbound Error','cancel',0,'',6,'2026-04-07 11:51:59','2026-04-07 11:54:04'),(4,1,8,23,56,7,4,2,'pending',NULL,NULL,NULL,NULL,NULL,NULL,'2026-04-09 12:37:46','2026-04-09 12:37:46'),(5,4,9,2,NULL,17,2,1,'pending',NULL,NULL,NULL,NULL,NULL,NULL,'2026-04-09 17:41:59','2026-04-09 17:41:59'),(6,5,12,2,NULL,20,8,5,'pending',NULL,NULL,NULL,NULL,NULL,NULL,'2026-04-17 15:31:18','2026-04-17 15:31:18');
/*!40000 ALTER TABLE `inventory_exceptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_allocations`
--

DROP TABLE IF EXISTS `order_allocations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_allocations` (
  `allocation_id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL,
  `order_item_id` bigint NOT NULL,
  `store_id` int NOT NULL,
  `assigned_worker_id` bigint DEFAULT NULL,
  `allocated_qty` int NOT NULL,
  `status` varchar(50) DEFAULT 'allocated',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`allocation_id`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_allocations`
--

LOCK TABLES `order_allocations` WRITE;
/*!40000 ALTER TABLE `order_allocations` DISABLE KEYS */;
INSERT INTO `order_allocations` VALUES (1,31,92,1,NULL,1,'allocated','2026-04-02 20:26:13'),(2,31,93,1,NULL,1,'allocated','2026-04-02 20:26:13'),(3,31,94,1,NULL,1,'allocated','2026-04-02 20:26:13'),(4,31,95,1,NULL,2,'allocated','2026-04-02 20:26:13'),(5,1,1,1,7,1,'partially_shipped','2026-04-02 20:56:16'),(6,1,2,1,7,1,'partially_shipped','2026-04-02 20:56:16'),(7,1,3,1,7,1,'partially_shipped','2026-04-02 20:56:16'),(8,1,4,1,7,1,'partially_shipped','2026-04-02 20:56:16'),(9,1,5,1,7,3,'partially_shipped','2026-04-02 20:56:16'),(10,3,9,4,NULL,1,'allocated','2026-04-03 21:33:16'),(11,3,10,2,NULL,1,'allocated','2026-04-03 21:33:16'),(12,3,11,2,NULL,1,'allocated','2026-04-03 21:33:16'),(13,3,12,1,7,1,'shipped','2026-04-03 21:33:16'),(14,3,13,1,7,3,'shipped','2026-04-03 21:33:16'),(15,3,14,1,7,13,'shipped','2026-04-03 21:33:16'),(16,4,16,3,NULL,1,'allocated','2026-04-04 13:01:23'),(17,4,17,2,NULL,1,'allocated','2026-04-04 13:01:23'),(18,4,18,1,NULL,1,'allocated','2026-04-04 13:01:23'),(19,4,19,1,NULL,1,'allocated','2026-04-04 13:01:23'),(20,4,20,1,NULL,1,'allocated','2026-04-04 13:01:23'),(21,5,23,4,NULL,1,'allocated','2026-04-07 08:28:28'),(22,6,24,1,7,2,'cancelled','2026-04-07 11:35:25'),(23,6,25,1,7,2,'cancelled','2026-04-07 11:35:25'),(24,6,26,1,7,3,'cancelled','2026-04-07 11:35:25'),(25,7,27,2,NULL,1,'allocated','2026-04-07 13:11:24'),(26,7,28,3,NULL,1,'allocated','2026-04-07 13:11:24'),(27,7,29,1,7,4,'shipped','2026-04-07 13:11:24'),(28,8,30,1,7,4,'partially_shipped','2026-04-09 12:36:42'),(29,8,31,1,7,1,'partially_shipped','2026-04-09 12:36:42'),(30,9,33,4,17,2,'partially_shipped','2026-04-09 17:36:13'),(31,9,34,4,17,2,'partially_shipped','2026-04-09 17:36:13'),(32,9,35,1,NULL,11,'allocated','2026-04-09 17:36:13'),(33,12,40,5,20,8,'partially_shipped','2026-04-17 15:14:57');
/*!40000 ALTER TABLE `order_allocations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_fulfillments`
--

DROP TABLE IF EXISTS `order_fulfillments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_fulfillments` (
  `fulfillment_id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL,
  `store_id` int NOT NULL,
  `status` varchar(50) NOT NULL,
  `tracking_number` varchar(255) DEFAULT NULL,
  `shipped_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`fulfillment_id`),
  KEY `order_id` (`order_id`),
  CONSTRAINT `order_fulfillments_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_fulfillments`
--

LOCK TABLES `order_fulfillments` WRITE;
/*!40000 ALTER TABLE `order_fulfillments` DISABLE KEYS */;
INSERT INTO `order_fulfillments` VALUES (1,3,1,'shipped',NULL,'2026-04-03 22:30:48','2026-04-03 22:30:48'),(2,3,1,'shipped',NULL,'2026-04-04 12:08:12','2026-04-04 12:08:12'),(3,3,1,'shipped',NULL,'2026-04-07 07:45:06','2026-04-07 07:45:06'),(4,3,1,'shipped',NULL,'2026-04-07 07:47:02','2026-04-07 07:47:02'),(5,3,1,'shipped',NULL,'2026-04-07 07:48:17','2026-04-07 07:48:17'),(6,3,1,'shipped',NULL,'2026-04-07 07:52:05','2026-04-07 07:52:05'),(7,3,1,'shipped',NULL,'2026-04-07 08:08:05','2026-04-07 08:08:05'),(8,1,1,'partially_shipped',NULL,'2026-04-07 11:33:04','2026-04-07 11:33:04'),(9,6,1,'partially_shipped',NULL,'2026-04-07 11:51:59','2026-04-07 11:51:59'),(10,7,1,'shipped',NULL,'2026-04-07 13:13:02','2026-04-07 13:13:02'),(11,8,1,'partially_shipped',NULL,'2026-04-09 12:37:46','2026-04-09 12:37:46'),(12,9,4,'partially_shipped',NULL,'2026-04-09 17:41:59','2026-04-09 17:41:59'),(13,12,5,'partially_shipped',NULL,'2026-04-17 15:31:18','2026-04-17 15:31:18');
/*!40000 ALTER TABLE `order_fulfillments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_items` (
  `order_item_id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  `variant_id` bigint DEFAULT NULL,
  `product_name` varchar(255) NOT NULL,
  `quantity` int NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`order_item_id`),
  KEY `order_id` (`order_id`),
  CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items`
--

LOCK TABLES `order_items` WRITE;
/*!40000 ALTER TABLE `order_items` DISABLE KEYS */;
INSERT INTO `order_items` VALUES (1,1,1,NULL,'Enterprise Laptop X1',1,1200.00,'2026-04-03 02:25:16'),(2,1,2,NULL,'Wireless Conference Phone',1,350.00,'2026-04-03 02:25:16'),(3,1,3,1,'Ergonomic Mesh Chair',1,250.00,'2026-04-03 02:25:16'),(4,1,3,2,'Ergonomic Mesh Chair',1,260.00,'2026-04-03 02:25:16'),(5,1,23,54,'EcoClean Commercial Foaming Hand Sanitizer (1 Gallon)',3,45.00,'2026-04-03 02:25:16'),(8,2,23,54,'EcoClean Commercial Foaming Hand Sanitizer (1 Gallon)',2,45.00,'2026-04-03 02:38:42'),(9,3,1,NULL,'Enterprise Laptop X1',1,1200.00,'2026-04-04 03:00:50'),(10,3,2,NULL,'Wireless Conference Phone',1,350.00,'2026-04-04 03:00:50'),(11,3,3,1,'Ergonomic Mesh Chair',1,250.00,'2026-04-04 03:00:50'),(12,3,3,2,'Ergonomic Mesh Chair',1,260.00,'2026-04-04 03:00:50'),(13,3,23,54,'EcoClean Commercial Foaming Hand Sanitizer (1 Gallon)',3,45.00,'2026-04-04 03:00:50'),(14,3,29,NULL,'rvvr',13,20.00,'2026-04-04 03:00:50'),(16,4,1,NULL,'Enterprise Laptop X1',1,1200.00,'2026-04-04 18:29:37'),(17,4,2,NULL,'Wireless Conference Phone',1,350.00,'2026-04-04 18:29:37'),(18,4,27,NULL,'ewdew',1,20.00,'2026-04-04 18:29:37'),(19,4,28,NULL,'efewf',1,2.00,'2026-04-04 18:29:37'),(20,4,29,NULL,'rvvr',1,200.00,'2026-04-04 18:29:37'),(23,5,30,NULL,'dfwd',1,22.00,'2026-04-07 13:58:02'),(24,6,1,NULL,'Enterprise Laptop X1',2,1200.00,'2026-04-07 17:04:09'),(25,6,2,NULL,'Wireless Conference Phone',2,350.00,'2026-04-07 17:04:09'),(26,6,3,1,'Ergonomic Mesh Chair',3,250.00,'2026-04-07 17:04:09'),(27,7,1,NULL,'Enterprise Laptop X1',1,1200.00,'2026-04-07 18:40:11'),(28,7,2,NULL,'Wireless Conference Phone',1,350.00,'2026-04-07 18:40:11'),(29,7,23,55,'EcoClean Commercial Foaming Hand Sanitizer (1 Gallon)',4,48.00,'2026-04-07 18:40:11'),(30,8,23,56,'EcoClean Commercial Foaming Hand Sanitizer (1 Gallon)',4,46.00,'2026-04-09 18:06:18'),(31,8,26,NULL,'fwfw',1,122.00,'2026-04-09 18:06:18'),(33,9,1,NULL,'Enterprise Laptop X1',2,1200.00,'2026-04-09 22:31:18'),(34,9,2,NULL,'Wireless Conference Phone',2,350.00,'2026-04-09 22:31:18'),(35,9,23,54,'EcoClean Commercial Foaming Hand Sanitizer (1 Gallon)',11,45.00,'2026-04-09 22:31:18'),(36,10,23,54,'EcoClean Commercial Foaming Hand Sanitizer (1 Gallon)',2,45.00,'2026-04-17 19:55:52'),(37,10,23,55,'EcoClean Commercial Foaming Hand Sanitizer (1 Gallon)',3,48.00,'2026-04-17 19:55:52'),(38,10,23,56,'EcoClean Commercial Foaming Hand Sanitizer (1 Gallon)',2,46.00,'2026-04-17 19:55:52'),(39,11,23,56,'EcoClean Commercial Foaming Hand Sanitizer (1 Gallon)',10,46.00,'2026-04-17 19:57:28'),(40,12,2,NULL,'Wireless Conference Phone',8,350.00,'2026-04-17 20:08:38');
/*!40000 ALTER TABLE `order_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `order_id` bigint NOT NULL AUTO_INCREMENT,
  `order_number` varchar(50) NOT NULL,
  `user_id` bigint DEFAULT NULL,
  `guest_email` varchar(255) DEFAULT NULL,
  `order_status` varchar(50) NOT NULL DEFAULT 'pending',
  `total_amount` decimal(10,2) NOT NULL,
  `shipping_address` text NOT NULL,
  `billing_address` text NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `store_id` int DEFAULT NULL,
  `approval_status` enum('approved','pending_approval','rejected') DEFAULT 'approved',
  `approved_by` bigint DEFAULT NULL,
  `assigned_worker_id` bigint DEFAULT NULL,
  `approval_date` datetime DEFAULT NULL,
  `assigned_by` bigint DEFAULT NULL,
  PRIMARY KEY (`order_id`),
  UNIQUE KEY `order_number` (`order_number`),
  KEY `user_id` (`user_id`),
  KEY `fk_order_store` (`store_id`),
  KEY `fk_order_approver` (`approved_by`),
  KEY `fk_order_worker` (`assigned_worker_id`),
  CONSTRAINT `fk_order_approver` FOREIGN KEY (`approved_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_order_store` FOREIGN KEY (`store_id`) REFERENCES `stores` (`store_id`),
  CONSTRAINT `fk_order_worker` FOREIGN KEY (`assigned_worker_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL,
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,'ORD-1775163316',1,NULL,'shipped',2304.75,'595 Market, St San Francisco, San Fransico, CA, 94105, United States','595 Market, St San Francisco, San Fransico, CA, 94105, United States','2026-04-03 02:25:16','2026-04-07 17:03:04',NULL,'approved',NULL,NULL,NULL,NULL),(2,'ORD-1775164122',1,NULL,'cancelled',94.50,'595 Market, St San Francisco, San Fransico, CA, 94105, United States','595 Market, St San Francisco, San Fransico, CA, 94105, United States','2026-04-03 02:38:42','2026-04-07 17:53:27',NULL,'approved',NULL,NULL,NULL,NULL),(3,'ORD-1775251850',1,NULL,'partially_shipped',2577.75,'595 Market, St San Francisco, San Fransico, CA, 94105, United States','595 Market, St San Francisco, San Fransico, CA, 94105, United States','2026-04-04 03:00:50','2026-04-07 13:38:05',NULL,'approved',NULL,NULL,NULL,NULL),(4,'ORD-1775307577',1,NULL,'processing',1860.60,'595 Market, St San Francisco, San Fransico, CA, 94105, United States','595 Market, St San Francisco, San Fransico, CA, 94105, United States','2026-04-04 18:29:37','2026-04-04 18:31:23',NULL,'approved',NULL,NULL,NULL,NULL),(5,'ORD-1775550482',1,NULL,'processing',23.10,'595 Market, St San Francisco, San Fransico, CA, 94105, United States','595 Market, St San Francisco, San Fransico, CA, 94105, United States','2026-04-07 13:58:02','2026-04-07 13:58:28',NULL,'approved',NULL,NULL,NULL,NULL),(6,'ORD-1775561649',12,NULL,'cancelled',4042.50,'80/1A SL Das Lane Hooghly, Kolkata, West Bengal, 713301, India','80/1A SL Das Lane Hooghly, Kolkata, West Bengal, 713301, India','2026-04-07 17:04:09','2026-04-07 17:53:02',NULL,'approved',NULL,NULL,NULL,NULL),(7,'ORD-1775567411',12,NULL,'partially_shipped',1829.10,'80/1A SL Das Lane Hooghly, Kolkata, West Bengal, 713301, India','80/1A SL Das Lane Hooghly, Kolkata, West Bengal, 713301, India','2026-04-07 18:40:11','2026-04-07 18:43:02',NULL,'approved',NULL,NULL,NULL,NULL),(8,'ORD-1775738178',1,NULL,'shipped',321.30,'595 Market, St San Francisco, San Fransico, CA, 94105, United States','595 Market, St San Francisco, San Fransico, CA, 94105, United States','2026-04-09 18:06:18','2026-04-09 18:07:46',NULL,'approved',NULL,NULL,NULL,NULL),(9,'ORD-1775754078',12,NULL,'partially_shipped',3784.75,'80/1A SL Das Lane Hooghly, Kolkata, West Bengal, 713301, India','80/1A SL Das Lane Hooghly, Kolkata, West Bengal, 713301, India','2026-04-09 22:31:18','2026-04-09 23:11:59',NULL,'approved',NULL,NULL,NULL,NULL),(10,'ORD-1776435952',12,NULL,'pending',361.27,'80/1A SL Das Lane Hooghly, Kolkata, West Bengal, 713301, India','80/1A SL Das Lane Hooghly, Kolkata, West Bengal, 713301, India','2026-04-17 19:55:52','2026-04-17 19:55:52',NULL,'approved',NULL,NULL,NULL,NULL),(11,'ORD-1776436048',12,NULL,'pending',505.65,'80/1A SL Das Lane Hooghly, Kolkata, West Bengal, 713301, India','80/1A SL Das Lane Hooghly, Kolkata, West Bengal, 713301, India','2026-04-17 19:57:28','2026-04-17 19:57:28',NULL,'approved',NULL,NULL,NULL,NULL),(12,'ORD-1776436718',12,NULL,'shipped',3027.00,'80/1A SL Das Lane Hooghly, Kolkata, West Bengal, 713301, India','80/1A SL Das Lane Hooghly, Kolkata, West Bengal, 713301, India','2026-04-17 20:08:38','2026-04-17 21:01:18',NULL,'approved',NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_bundles`
--

DROP TABLE IF EXISTS `product_bundles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_bundles` (
  `bundle_id` int NOT NULL AUTO_INCREMENT,
  `parent_product_id` int NOT NULL,
  `child_product_id` int NOT NULL,
  `quantity_in_bundle` int DEFAULT '1',
  PRIMARY KEY (`bundle_id`),
  KEY `parent_product_id` (`parent_product_id`),
  KEY `child_product_id` (`child_product_id`),
  CONSTRAINT `product_bundles_ibfk_1` FOREIGN KEY (`parent_product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE,
  CONSTRAINT `product_bundles_ibfk_2` FOREIGN KEY (`child_product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_bundles`
--

LOCK TABLES `product_bundles` WRITE;
/*!40000 ALTER TABLE `product_bundles` DISABLE KEYS */;
INSERT INTO `product_bundles` VALUES (1,11,7,1),(2,11,10,1);
/*!40000 ALTER TABLE `product_bundles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_downloads`
--

DROP TABLE IF EXISTS `product_downloads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_downloads` (
  `download_id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `file_url` varchar(255) NOT NULL,
  `access_days` int DEFAULT NULL,
  `download_limit` int DEFAULT NULL,
  PRIMARY KEY (`download_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `product_downloads_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_downloads`
--

LOCK TABLES `product_downloads` WRITE;
/*!40000 ALTER TABLE `product_downloads` DISABLE KEYS */;
INSERT INTO `product_downloads` VALUES (1,8,'https://s3.amazon.com/bucket/coding-guide.pdf',NULL,5);
/*!40000 ALTER TABLE `product_downloads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_media`
--

DROP TABLE IF EXISTS `product_media`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_media` (
  `media_id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `variant_id` bigint DEFAULT NULL,
  `media_type` enum('image','video') DEFAULT 'image',
  `media_url` varchar(500) NOT NULL COMMENT 'Path to file (e.g., /static/uploads/...) or external URL',
  `display_order` int DEFAULT '0',
  PRIMARY KEY (`media_id`),
  KEY `fk_media_product` (`product_id`),
  KEY `fk_media_variant` (`variant_id`),
  CONSTRAINT `fk_media_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_media_variant` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`variant_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_media`
--

LOCK TABLES `product_media` WRITE;
/*!40000 ALTER TABLE `product_media` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_media` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_subscriptions`
--

DROP TABLE IF EXISTS `product_subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_subscriptions` (
  `subscription_id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `frequency_value` int NOT NULL,
  `frequency_unit` enum('day','week','month','year') NOT NULL,
  `price_per_cycle` decimal(10,2) NOT NULL,
  PRIMARY KEY (`subscription_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `product_subscriptions_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_subscriptions`
--

LOCK TABLES `product_subscriptions` WRITE;
/*!40000 ALTER TABLE `product_subscriptions` DISABLE KEYS */;
INSERT INTO `product_subscriptions` VALUES (1,9,1,'month',19.99);
/*!40000 ALTER TABLE `product_subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_variants`
--

DROP TABLE IF EXISTS `product_variants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_variants` (
  `variant_id` bigint NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `sku` varchar(100) DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `stock_quantity` int DEFAULT '0',
  `image_url` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`variant_id`),
  UNIQUE KEY `sku` (`sku`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `product_variants_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_variants`
--

LOCK TABLES `product_variants` WRITE;
/*!40000 ALTER TABLE `product_variants` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_variants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `product_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` text,
  `specifications` text,
  `price` decimal(10,2) NOT NULL,
  `stock_quantity` int DEFAULT '100',
  `image_url` varchar(255) DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `brand_id` int DEFAULT NULL,
  `category_id` int DEFAULT NULL,
  `product_type` enum('simple','downloadable','recurring','rental','grouped','bundle') DEFAULT 'simple',
  `has_variants` tinyint(1) DEFAULT '0',
  `showcase` text COMMENT 'Product Highlights/Key Features (Bullet points)',
  `product_definition` text COMMENT 'Detailed Product Description',
  `features` text COMMENT 'Additional Features text',
  `warranty_info` text COMMENT 'Warranty Summary',
  `manufacturer_info` text COMMENT 'Manufacturing & Import Details',
  PRIMARY KEY (`product_id`),
  KEY `fk_product_brand` (`brand_id`),
  KEY `fk_product_category` (`category_id`),
  CONSTRAINT `fk_product_brand` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`brand_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_product_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `regions`
--

DROP TABLE IF EXISTS `regions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `regions` (
  `region_id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `code` varchar(20) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`region_id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `regions`
--

LOCK TABLES `regions` WRITE;
/*!40000 ALTER TABLE `regions` DISABLE KEYS */;
INSERT INTO `regions` VALUES (1,'USA - East Coast','US-EAST',1,'2026-02-19 19:01:37'),(2,'USA - West Coast','US-WEST',1,'2026-02-19 19:01:37'),(3,'USA - South','US-SOUTH',1,'2026-02-19 19:01:37');
/*!40000 ALTER TABLE `regions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `restaurants`
--

DROP TABLE IF EXISTS `restaurants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `restaurants` (
  `restaurant_id` int NOT NULL AUTO_INCREMENT,
  `restaurant_name` varchar(100) NOT NULL,
  `restaurant_code` varchar(50) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `state` varchar(100) DEFAULT NULL,
  `zip` varchar(20) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `tax_rate` decimal(5,2) DEFAULT '0.00',
  PRIMARY KEY (`restaurant_id`),
  UNIQUE KEY `restaurant_code` (`restaurant_code`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `restaurants`
--

LOCK TABLES `restaurants` WRITE;
/*!40000 ALTER TABLE `restaurants` DISABLE KEYS */;
INSERT INTO `restaurants` VALUES (1,'Chipotle 001','ChP-001','610 Newport Center Drive, Newport Beach, California 92660, USA','California','CA','92660',1,'2026-03-28 13:47:48','2026-04-16 14:03:34',6.77),(2,'Chipotle-004','Chp-004','500 Neil Ave., Columbus, Ohio 43215, USA.','New York','NY','43215',1,'2026-03-28 13:49:32','2026-04-16 14:03:52',8.65),(3,'Chipotle 003','ChP-003','610 Newport Center Drive, Newport Beach, California 92660, USA','New Port','California, CA','92660',1,'2026-04-13 11:03:56','2026-04-16 14:03:43',3.88),(4,'Harbor Center - 147','147','Costa Mesa','Costa Mesa','CA','92626',1,'2026-04-16 14:02:46','2026-04-16 14:02:46',7.75),(5,'Pacific Beach - 199','199','CA','San Diego','CA','92109',1,'2026-04-16 14:34:24','2026-04-16 14:34:57',7.75),(6,'Howe & Arden - 200','200','CA','Sacramento','CA','95825',1,'2026-04-16 14:34:24','2026-04-16 14:34:45',7.75);
/*!40000 ALTER TABLE `restaurants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sku_attribute_values`
--

DROP TABLE IF EXISTS `sku_attribute_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sku_attribute_values` (
  `value_id` bigint NOT NULL AUTO_INCREMENT,
  `attribute_id` bigint NOT NULL,
  `attribute_value` varchar(100) NOT NULL,
  `color_code` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `unique_attr_val` (`attribute_id`,`attribute_value`),
  CONSTRAINT `sku_attribute_values_ibfk_1` FOREIGN KEY (`attribute_id`) REFERENCES `sku_attributes` (`attribute_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sku_attribute_values`
--

LOCK TABLES `sku_attribute_values` WRITE;
/*!40000 ALTER TABLE `sku_attribute_values` DISABLE KEYS */;
INSERT INTO `sku_attribute_values` VALUES (1,1,'Black','#000000','2026-02-20 14:09:31'),(2,1,'White','#FFFFFF','2026-02-20 14:09:31'),(3,1,'Grey','#808080','2026-02-20 14:09:31'),(4,2,'48 Inch',NULL,'2026-02-20 14:09:31'),(5,2,'60 Inch',NULL,'2026-02-20 14:09:31'),(30,11,'48x24',NULL,'2026-03-19 17:58:53'),(31,11,'60x24',NULL,'2026-03-19 17:58:55'),(32,11,'72x30',NULL,'2026-03-19 17:58:56'),(33,12,'50 inch',NULL,'2026-03-20 20:53:59'),(34,12,'20 inch',NULL,'2026-03-20 20:54:10'),(35,12,'48 Inch',NULL,'2026-03-20 21:43:51'),(36,12,'60 Inch',NULL,'2026-03-20 21:43:52'),(37,12,'72 Inch',NULL,'2026-03-20 21:43:53'),(38,13,'Fragrance-Free',NULL,'2026-03-23 16:48:59'),(39,13,'Citrus Breeze',NULL,'2026-03-23 16:49:01'),(40,13,'Rose-Lilly mash',NULL,'2026-03-23 16:49:04');
/*!40000 ALTER TABLE `sku_attribute_values` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sku_attributes`
--

DROP TABLE IF EXISTS `sku_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sku_attributes` (
  `attribute_id` bigint NOT NULL AUTO_INCREMENT,
  `attribute_name` varchar(100) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`attribute_id`),
  UNIQUE KEY `attribute_name` (`attribute_name`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sku_attributes`
--

LOCK TABLES `sku_attributes` WRITE;
/*!40000 ALTER TABLE `sku_attributes` DISABLE KEYS */;
INSERT INTO `sku_attributes` VALUES (1,'Color','2026-02-20 14:09:31'),(2,'Size','2026-02-20 14:09:31'),(11,'Dimensions','2026-03-19 17:58:53'),(12,'Width','2026-03-20 20:53:59'),(13,'Scent','2026-03-23 16:48:59');
/*!40000 ALTER TABLE `sku_attributes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sku_inventory`
--

DROP TABLE IF EXISTS `sku_inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sku_inventory` (
  `inventory_id` bigint NOT NULL AUTO_INCREMENT,
  `store_id` int NOT NULL,
  `sku_id` bigint NOT NULL,
  `variant_id` bigint DEFAULT NULL,
  `quantity` int NOT NULL DEFAULT '0',
  `low_stock_threshold` int DEFAULT '5',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`inventory_id`),
  UNIQUE KEY `uk_store_sku_variant` (`store_id`,`sku_id`,`variant_id`),
  KEY `fk_inv_store_new` (`store_id`),
  KEY `fk_inv_sku_new` (`sku_id`),
  KEY `fk_inventory_variant` (`variant_id`),
  CONSTRAINT `fk_inv_sku_new` FOREIGN KEY (`sku_id`) REFERENCES `sku_master` (`sku_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_inv_store_new` FOREIGN KEY (`store_id`) REFERENCES `stores` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_inventory_variant` FOREIGN KEY (`variant_id`) REFERENCES `sku_variant` (`variant_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=83 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sku_inventory`
--

LOCK TABLES `sku_inventory` WRITE;
/*!40000 ALTER TABLE `sku_inventory` DISABLE KEYS */;
INSERT INTO `sku_inventory` VALUES (1,1,1,NULL,0,20,'2026-04-07 17:23:26'),(2,1,2,NULL,100,15,'2026-04-09 22:37:50'),(5,1,5,NULL,1696,100,'2026-03-27 20:02:15'),(6,2,1,NULL,19,5,'2026-04-07 18:41:24'),(7,2,2,NULL,200,5,'2026-04-09 22:37:50'),(9,2,5,NULL,100,20,'2026-02-19 19:01:37'),(10,3,1,NULL,185,20,'2026-04-04 18:31:23'),(11,3,2,NULL,143,15,'2026-04-09 22:37:50'),(14,3,5,NULL,800,50,'2026-02-19 19:01:37'),(15,4,1,NULL,0,5,'2026-04-09 23:11:59'),(16,4,2,NULL,97,5,'2026-04-09 23:11:59'),(17,4,5,NULL,50,10,'2026-02-19 19:01:37'),(26,1,3,1,43,5,'2026-04-07 17:21:59'),(27,1,3,2,0,5,'2026-04-07 17:18:10'),(28,1,4,3,0,2,'2026-03-12 22:19:13'),(29,1,4,4,59,3,'2026-04-03 02:35:11'),(30,2,3,1,4,1,'2026-04-04 03:03:16'),(31,2,3,2,5,1,'2026-02-24 01:20:38'),(32,3,3,1,30,5,'2026-02-27 14:12:56'),(33,3,3,2,35,5,'2026-03-11 15:27:39'),(34,3,4,3,7,2,'2026-02-24 02:01:13'),(35,3,4,4,17,3,'2026-02-24 02:01:13'),(52,4,14,NULL,0,0,'2026-03-19 23:28:52'),(53,1,14,NULL,0,0,'2026-03-19 23:28:52'),(54,1,15,NULL,0,0,'2026-03-20 03:03:42'),(55,1,16,NULL,100,1,'2026-04-03 02:35:57'),(57,1,18,NULL,100,1,'2026-04-03 02:35:57'),(60,4,20,NULL,100,50,'2026-03-21 02:44:20'),(61,1,20,NULL,100,20,'2026-03-21 02:22:00'),(62,1,21,51,65,10,'2026-03-27 20:02:15'),(63,1,21,52,49,15,'2026-03-27 20:02:15'),(64,1,21,53,43,14,'2026-03-27 20:02:15'),(65,1,23,54,455,20,'2026-04-09 23:06:13'),(66,1,23,55,388,20,'2026-04-07 18:43:02'),(67,1,23,56,240,15,'2026-04-09 18:07:46'),(68,1,25,57,700,60,'2026-03-24 02:29:45'),(69,1,25,58,100,10,'2026-03-24 02:29:47'),(70,1,26,NULL,98,60,'2026-04-09 18:07:46'),(71,1,27,NULL,0,1,'2026-04-04 18:31:23'),(72,1,28,NULL,19,5,'2026-04-04 18:31:23'),(73,1,29,NULL,0,1,'2026-04-07 13:38:05'),(74,4,30,NULL,200,40,'2026-04-08 22:20:18'),(75,1,30,NULL,400,50,'2026-04-08 22:20:18'),(76,4,30,59,100,1,'2026-04-09 01:58:42'),(77,4,30,60,100,1,'2026-04-09 01:58:42'),(78,4,30,61,100,1,'2026-04-09 01:58:42'),(79,1,30,59,100,1,'2026-04-09 01:58:42'),(80,1,30,60,100,1,'2026-04-09 01:58:42'),(81,1,30,61,100,1,'2026-04-09 01:58:42'),(82,5,2,NULL,187,1,'2026-04-17 21:01:18');
/*!40000 ALTER TABLE `sku_inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sku_master`
--

DROP TABLE IF EXISTS `sku_master`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sku_master` (
  `sku_id` bigint NOT NULL AUTO_INCREMENT,
  `sku` varchar(50) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `category_id` int DEFAULT NULL,
  `brand_id` int DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `specifications` text,
  `warranty_info` text,
  `manufacturer_info` text,
  `product_definition` text,
  `is_grouped_product` tinyint(1) DEFAULT '0',
  `gtin` varchar(100) DEFAULT NULL,
  `manufacturer_part_number` varchar(100) DEFAULT NULL,
  `old_price` decimal(10,2) DEFAULT NULL,
  `product_cost` decimal(10,2) DEFAULT NULL,
  `disable_buy_button` tinyint(1) DEFAULT '0',
  `call_for_price` tinyint(1) DEFAULT '0',
  `weight` decimal(10,2) DEFAULT '0.00',
  `length` decimal(10,2) DEFAULT '0.00',
  `width` decimal(10,2) DEFAULT '0.00',
  `height` decimal(10,2) DEFAULT '0.00',
  `minimum_cart_qty` int DEFAULT '1',
  `maximum_cart_qty` int DEFAULT '10000',
  `case_pack_quantity` int DEFAULT '1',
  `not_returnable` tinyint(1) DEFAULT '0',
  `admin_comment` text,
  PRIMARY KEY (`sku_id`),
  UNIQUE KEY `sku` (`sku`),
  KEY `fk_sku_category` (`category_id`),
  KEY `fk_sku_brand` (`brand_id`),
  CONSTRAINT `fk_sku_brand` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`brand_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_sku_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sku_master`
--

LOCK TABLES `sku_master` WRITE;
/*!40000 ALTER TABLE `sku_master` DISABLE KEYS */;
INSERT INTO `sku_master` VALUES (1,'TP-LAP-001','Enterprise Laptop X1','High performance laptop for business.',1200.00,1,1,'\\static\\images\\products\\backpack_front.jpg',1,'2026-02-19 19:01:37','2026-03-17 22:44:34','Processor: Intel Core i9 13th Gen\nRAM: 32GB DDR5\nStorage: 1TB NVMe SSD\nDisplay: 16-inch 4K OLED (3840x2400)\nBattery: 99.9Whr (Up to 12 hours)\nPorts: 2x Thunderbolt 4, 1x HDMI 2.1, 2x USB-A','3-Year Premium On-Site B2B Support. Covers accidental damage, battery degradation, and next-business-day hardware replacement.','TechPro Enterprise Solutions\n100 Silicon Way, San Jose, CA 95110\nImported directly via certified B2B channel partners. RoHS & Energy Star Certified.','The TechPro Ultimate Laptop is engineered specifically for enterprise professionals who demand uncompromising performance. Featuring an aerospace-grade aluminum chassis and military-spec durability, it handles complex data modeling, software compilation, and professional video rendering without breaking a sweat.\n\nBuilt-in hardware encryption ensures your corporate IP remains perfectly secure.',1,NULL,NULL,NULL,NULL,0,0,0.00,0.00,0.00,0.00,1,10000,1,0,NULL),(2,'TP-AUD-002','Wireless Conference Phone','Crystal clear audio for meetings.',350.00,1,1,'\\static\\images\\products\\wirelessphone.jpg',1,'2026-02-19 19:01:37','2026-04-09 22:37:50','','','','',0,'','',0.00,0.00,0,0,0.00,0.00,0.00,0.00,1,10000,1,0,''),(3,'EL-CHR-100','Ergonomic Mesh Chair','Comfortable chair for long hours.',250.00,3,3,'\\static\\images\\products\\backpack_front.jpg',1,'2026-02-19 19:01:37','2026-02-25 02:43:06','Material: Premium Breathable Mesh & High-Density Memory Foam\nWeight Capacity: Up to 350 lbs\nAdjustability: 4-Way Armrests, Dynamic Lumbar Support, Seat Depth Slider\nBase: Heavy-Duty Aluminum with 60mm PU Casters\nTilt: 135-degree synchronous tilt with 4 lock positions','12-Year Structural Warranty. 5-Year coverage on fabrics, armpads, and gas cylinders. Rated for 24/7 continuous enterprise use.','ErgoLine Furniture Co.\nManufactured in Taiwan. Final assembly and rigorous quality assurance testing completed in the USA.','Redefine your office ergonomics with our flagship chair. Designed over 4 years with leading physiotherapists, this chair actively maps to your spine\'s micro-movements throughout the workday. It completely eliminates lower back fatigue during 12+ hour corporate shifts, making it the standard issue seating for Fortune 500 tech campuses worldwide.',0,NULL,NULL,NULL,NULL,0,0,0.00,0.00,0.00,0.00,1,10000,1,0,NULL),(4,'EL-DSK-200','Standing Desk Pro','Adjustable height electric desk.',450.00,3,3,'\\static\\images\\products\\backpack_front.jpg',1,'2026-02-19 19:01:37','2026-02-20 18:01:19',NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,0,0,0.00,0.00,0.00,0.00,1,10000,1,0,NULL),(5,'OM-PAP-500','Bulk Copy Paper (Case)','10 Reams of 500 sheets.',45.00,2,2,'\\static\\images\\products\\backpack_front.jpg',1,'2026-02-19 19:01:37','2026-02-20 18:01:19',NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,0,0,0.00,0.00,0.00,0.00,1,10000,1,0,NULL),(14,'PRP-TBL-SS-001','Commercial Stainless Steel Prep Table','Heavy-duty 16-gauge stainless steel prep table with undershelf. NSF certified for commercial kitchens.',285.00,4,4,NULL,1,'2026-03-19 23:28:52','2026-03-19 23:28:52','Material: 16-Gauge Type 304 Stainless Steel\nCertification: NSF Listed\nLegs: 1-5/8\" Tubular Galvanized Steel\nWeight Capacity: 500 lbs','1-Year limited warranty against manufacturing defects. Ships unassembled (Knocked Down). Requires two-person lift team.','The Vollrath Company, LLC. Manufactured in the USA. ISO 9001 Certified.','Designed for high-volume commercial kitchens, this prep table features a durable 16-gauge type 304 stainless steel top that resists corrosion and is easy to clean. The adjustable galvanized undershelf provides extra storage for ingredients or equipment.',0,'00029419782194','V-SS-7230',350.00,190.00,0,0,65.50,72.00,30.00,35.00,1,25,1,0,''),(15,'btl-hLD-SS-001','Commercial Stainless Steel Bottle holder','Designed for high-volume commercial kitchens, this prep table features a durable 16-gauge type 304 stainless steel bottle holder that resists corrosion and is easy to clean. The adjustable galvanized holder provides extra storage for bottles or equipment.',500.00,4,4,NULL,1,'2026-03-20 03:03:42','2026-03-20 03:03:42','Material: 16-Gauge Type 304 Stainless Steel\nCertification: NSF Listed\nLegs: 1-5/8\" Tubular Galvanized Steel\nWeight Capacity: 500 lbs','1-Year limited warranty against manufacturing defects. Ships unassembled (Knocked Down). Requires two-person lift team.','The Vollrath Company, LLC. Manufactured in the USA. ISO 9001 Certified.','st-moving item. Ensure dual-pallet wrapping during outbound freight to prevent denting.',0,'00069419782167','V-SS-7230',560.00,360.00,0,0,720.00,20.00,10.00,40.00,1,10000,1,1,''),(16,'HDR-5000','Heavy-Duty Steel Storage Rack','Industrial-grade steel storage rack with 4 adjustable wire decking shelves.',180.00,5,5,NULL,1,'2026-03-20 22:55:00','2026-03-20 22:55:00','Material: Powder-Coated Steel\nShelf Capacity: 2000 lbs\nNSF Certified: Yes','5-Year Limited Manufacturer Warranty. Ships unassembled via LTL Freight.','Global Industrial Corporation. Manufactured in Taiwan.','Built for heavy-duty warehouse and backroom applications, this steel rack features powder-coated uprights and adjustable shelves. Each shelf safely holds up to 2,000 lbs of evenly distributed weight.',0,'00123456789012','GI-HDR-50',190.00,200.00,0,0,85.00,48.00,24.00,72.00,2,50,1,0,'High freight cost item. Ensure pallet wrapping.'),(18,'HDR-5000-2','Heavy-Duty Steel Storage Rack 2','Industrial-grade steel storage rack with 4 adjustable wire decking shelves.',300.00,5,5,NULL,1,'2026-03-21 01:31:39','2026-03-21 01:31:39','Material: Powder-Coated Steel\nShelf Capacity: 2000 lbs\nNSF Certified: Yes','5-Year Limited Manufacturer Warranty. Ships unassembled via LTL Freight.','Global Industrial Corporation. Manufactured in Taiwan.','Built for heavy-duty warehouse and backroom applications, this steel rack features powder-coated uprights and adjustable shelves. Each shelf safely holds up to 2,000 lbs of evenly distributed weight.',0,'00123456789013','GI-HDR-50',290.00,190.00,0,0,85.00,50.00,24.00,72.00,2,50,1,0,'High freight cost item. Ensure pallet wrapping.'),(20,'HDR-5000-3','Heavy-Duty Steel Storage Rack 3','Industrial-grade steel storage rack with 4 adjustable wire decking shelves.',300.00,5,5,NULL,1,'2026-03-21 02:22:00','2026-03-21 02:22:00','Material: Powder-Coated Steel\nShelf Capacity: 2000 lbs\nNSF Certified: Yes','5-Year Limited Manufacturer Warranty. Ships unassembled via LTL Freight.','Global Industrial Corporation. Manufactured in Taiwan.','Built for heavy-duty warehouse and backroom applications, this steel rack features powder-coated uprights and adjustable shelves. Each shelf safely holds up to 2,000 lbs of evenly distributed weight.',0,'00123456789014','',290.00,150.00,0,0,48.00,70.00,20.00,80.00,2,5000,1,0,'High freight cost item. Ensure pallet wrapping.'),(21,'HDR-5000-4','Heavy-Duty Steel Storage Rack 4','Industrial-grade steel storage rack with 4 adjustable wire decking shelves.',300.00,5,5,NULL,1,'2026-03-21 03:13:49','2026-03-21 03:13:49','Material: Powder-Coated Steel\nShelf Capacity: 2000 lbs\nNSF Certified: Yes','5-Year Limited Manufacturer Warranty. Ships unassembled via LTL Freight.\n\n',' Global Industrial Corporation. Manufactured in Taiwan.','Built for heavy-duty warehouse and backroom applications, this steel rack features powder-coated uprights and adjustable shelves. Each shelf safely holds up to 2,000 lbs of evenly distributed weight.',0,'00123456789015','',290.00,156.00,0,0,70.00,60.00,20.00,89.00,1,100,1,0,'High freight cost item. Ensure pallet wrapping.'),(23,'ECO-SAN-1G','EcoClean Commercial Foaming Hand Sanitizer (1 Gallon)','High-capacity foaming hand sanitizer refill. Fits universal dispensers.',45.00,6,6,NULL,1,'2026-03-23 22:18:58','2026-03-23 22:18:58','Active Ingredient: Benzalkonium Chloride 0.13%\nVolume: 1 Gallon (128 fl oz) per jug\nColor: Clear\nFormat: Foaming Liquid','Shelf life: 24 months from manufacture date. Keep away from excessive heat or open flames.','EcoClean Pro Industries, LLC. Made in USA. FDA Registered Facility.','Formulated for high-traffic commercial facilities. Kills 99.9% of germs while remaining gentle on hands with aloe and vitamin E. Designed to fit all standard universal bulk foam dispensers.',0,'00812345678905','EC-FHS-1G-PRO',60.00,22.50,0,0,35.10,13.00,13.00,12.50,2,200,4,1,'High turnover consumable. Store in temperature-controlled aisles (Do not freeze).'),(25,'ECO-SAN-1G-2','EcoClean Commercial Foaming Hand Sanitizer 2 (1 Gallon)','High-capacity foaming hand sanitizer refill. Fits universal dispensers.',45.00,6,6,NULL,0,'2026-03-24 02:29:42','2026-03-24 02:29:42','Active Ingredient: Benzalkonium Chloride 0.13%\nVolume: 1 Gallon (128 fl oz) per jug\nColor: Clear\nFormat: Foaming Liquid','Shelf life: 24 months from manufacture date. Keep away from excessive heat or open flames.','EcoClean Pro Industries, LLC. Made in USA. FDA Registered Facility.','Formulated for high-traffic commercial facilities. Kills 99.9% of germs while remaining gentle on hands with aloe and vitamin E. Designed to fit all standard universal bulk foam dispensers.',0,'00812345678905','EC-FHS-1G-PRO',60.00,22.50,0,0,60.00,70.00,20.00,50.00,1,2000,10,1,'High turnover consumable. Store in temperature-controlled aisles (Do not freeze).'),(26,'efwf','fwfw','ewff',122.00,4,1,NULL,1,'2026-03-27 18:52:03','2026-03-27 18:52:03','ef3f','3f','f3f','wefwe',0,'dewdwe','ewfewfd',112.00,123.00,0,0,100.00,30.00,50.00,50.00,1,10000,1,0,'ewfw'),(27,'wedwd','ewdew','',20.00,4,2,NULL,1,'2026-03-27 19:18:11','2026-03-27 19:18:11','','','','',0,'wefew','ewewf',39.00,10.00,0,0,0.00,0.00,0.00,0.00,1,10000,1,0,''),(28,'fewf','efewf','',2.00,6,3,NULL,1,'2026-03-27 19:51:05','2026-03-27 19:51:05','','','','',0,'','',NULL,NULL,0,0,0.00,0.00,0.00,0.00,1,10000,1,0,''),(29,'rvr','rvvr','',200.00,1,5,NULL,1,'2026-04-03 18:14:47','2026-04-03 18:14:47','dfsf','dvdv','vdfv','',0,'','',100.00,130.00,0,0,0.00,0.00,0.00,0.00,1,10000,1,0,''),(30,'MEW MEW ','MEW MEW','MEW MEW MEW ',22.00,3,2,'/static/uploads/products/sku_30_master_oil_canola2.jpg',1,'2026-04-07 13:56:59','2026-04-09 01:58:42','MEW MEW MEW MEW MEW MEW MEW MEW ','MEW MEW MEW MEW MEW ','MEW MEW MEW MEW MEW MEW ','MEW MEW MEW MEW ',0,'wdcw','wdf',30.00,10.00,0,0,0.00,0.00,0.00,0.00,1,10000,2,0,'MEW MEW MEW'),(31,'COF-100','Signature Blend Coffee','Premium roasted beans.',15.99,7,7,'https://example.com/coffee.jpg',1,'2026-04-13 20:33:20','2026-04-14 01:34:12','Roast: Dark\nOrigin: Columbia','1 Year guarantee','Imported by CafeBrand LLC','Imported directly from Columbia. Best served black.',0,'123456789012','CB-01',19.99,8.00,0,0,1.00,5.00,4.00,8.00,1,100,12,0,'Seasonal item'),(32,'APR-200','Barista Apron','Durable canvas apron.',24.99,8,7,'https://example.com/apron.jpg',1,'2026-04-13 20:33:20','2026-04-14 01:34:12','Material: Canvas','','','',0,'','',29.99,12.00,0,0,0.50,10.00,10.00,1.00,1,50,1,0,'');
/*!40000 ALTER TABLE `sku_master` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sku_media`
--

DROP TABLE IF EXISTS `sku_media`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sku_media` (
  `media_id` bigint NOT NULL AUTO_INCREMENT,
  `sku_id` bigint NOT NULL,
  `variant_id` bigint DEFAULT NULL,
  `media_type` enum('image','video') NOT NULL DEFAULT 'image',
  `media_url` varchar(500) NOT NULL,
  `display_order` int DEFAULT '0',
  `is_primary` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`media_id`),
  KEY `sku_id` (`sku_id`),
  CONSTRAINT `sku_media_ibfk_1` FOREIGN KEY (`sku_id`) REFERENCES `sku_master` (`sku_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sku_media`
--

LOCK TABLES `sku_media` WRITE;
/*!40000 ALTER TABLE `sku_media` DISABLE KEYS */;
INSERT INTO `sku_media` VALUES (1,1,NULL,'image','\\static\\images\\products\\laptop.jpeg',0,1,'2026-02-20 14:09:31'),(4,1,NULL,'video','\\static\\images\\products\\laptop.mp4',3,0,'2026-02-20 14:09:31'),(5,3,NULL,'image','\\static\\images\\products\\chairs.jpg',0,1,'2026-02-20 14:09:31'),(6,3,NULL,'image','\\static\\images\\products\\chairs2.webp',1,0,'2026-02-20 14:09:31'),(7,4,3,'image','\\static\\images\\products\\deskblack.webp',4,0,'2026-02-20 14:09:31'),(8,4,4,'image','\\static\\images\\products\\deskwhite.webp',5,0,'2026-02-20 14:09:31'),(9,2,NULL,'image','\\static\\images\\products\\wirelessphone.jpg',6,0,'2026-02-20 14:09:31'),(10,5,NULL,'image','\\static\\images\\products\\paper.jpeg',7,0,'2026-02-20 14:09:31'),(11,14,NULL,'image','/static/uploads/products/sku_14_prp_table.jpeg',0,1,'2026-03-19 17:58:56'),(12,14,NULL,'image','/static/uploads/products/sku_14_prp_tab_2.jpeg',1,0,'2026-03-19 17:58:56'),(13,20,49,'image','/static/uploads/products/sku_20_var_49_rack_2_2.webp',0,1,'2026-03-20 20:54:05'),(14,20,50,'image','/static/uploads/products/sku_20_var_50_rack_1.jpeg',0,1,'2026-03-20 20:54:14'),(15,21,51,'image','/static/uploads/products/sku_21_var_51_rack_2_2.webp',0,1,'2026-03-20 21:43:52'),(16,21,52,'image','/static/uploads/products/sku_21_var_52_rack.webp',0,1,'2026-03-20 21:43:53'),(17,21,53,'image','/static/uploads/products/sku_21_var_53_rack_1.jpeg',0,1,'2026-03-20 21:43:54'),(18,23,54,'image','/static/uploads/products/sku_23_var_54_handwash1.jpg',0,1,'2026-03-23 16:49:00'),(19,23,55,'image','/static/uploads/products/sku_23_var_55_images.jpeg',0,1,'2026-03-23 16:49:02'),(20,23,56,'image','/static/uploads/products/sku_23_var_56_1000ml-Deftton-Rose-Hand-Sanitizer.jpg',0,1,'2026-03-23 16:49:04'),(21,25,57,'image','/static/uploads/products/sku_25_var_57_handwash1.jpg',0,1,'2026-03-23 20:59:45'),(22,25,58,'image','/static/uploads/products/sku_25_var_58_images.jpeg',0,1,'2026-03-23 20:59:47'),(23,26,NULL,'image','/static/uploads/products/sku_26_master_oil_canola3.jpg',0,1,'2026-03-27 13:22:03'),(24,27,NULL,'image','/static/uploads/products/sku_27_master_citrus.webp',0,1,'2026-03-27 13:48:11'),(25,30,NULL,'image','/static/uploads/products/sku_30_master_oil_canola2.jpg',0,1,'2026-04-07 08:26:59'),(26,30,NULL,'image','/static/uploads/products/1775664000_oil_canola.jpg',0,0,'2026-04-08 16:00:00'),(27,30,59,'image','/static/uploads/products/1775680080_handwash1.jpg',0,1,'2026-04-08 20:28:00'),(28,30,60,'image','/static/uploads/products/1775680080_oil_canola2.jpg',0,1,'2026-04-08 20:28:00'),(29,30,61,'image','/static/uploads/products/1775680080_citrus.webp',0,1,'2026-04-08 20:28:00'),(30,31,NULL,'image','https://example.com/coffee.jpg',0,1,'2026-04-13 20:03:20'),(31,32,NULL,'image','https://example.com/apron.jpg',0,1,'2026-04-13 20:03:20'),(32,32,62,'image','https://example.com/apron-small.jpg',0,1,'2026-04-13 20:03:21'),(33,32,63,'image','https://example.com/apron-large.jpg',0,1,'2026-04-13 20:03:21');
/*!40000 ALTER TABLE `sku_media` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sku_variant`
--

DROP TABLE IF EXISTS `sku_variant`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sku_variant` (
  `variant_id` bigint NOT NULL AUTO_INCREMENT,
  `sku_id` bigint NOT NULL,
  `combination_key` varchar(255) NOT NULL,
  `sku` varchar(100) NOT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `image_url` varchar(500) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`variant_id`),
  KEY `sku_id` (`sku_id`),
  CONSTRAINT `sku_variant_ibfk_1` FOREIGN KEY (`sku_id`) REFERENCES `sku_master` (`sku_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sku_variant`
--

LOCK TABLES `sku_variant` WRITE;
/*!40000 ALTER TABLE `sku_variant` DISABLE KEYS */;
INSERT INTO `sku_variant` VALUES (1,3,'Black','EL-CHR-100-BLK',250.00,'\\static\\images\\products\\chairs.jpg','2026-02-20 14:09:31'),(2,3,'Grey','EL-CHR-100-GRY',260.00,'\\static\\images\\products\\chairs2.webp','2026-02-20 14:09:31'),(3,4,'48 Inch-Black','EL-DSK-200-48B',450.00,'https://placehold.co/400x400/png?text=Desk+48+Black','2026-02-20 14:09:31'),(4,4,'60 Inch-White','EL-DSK-200-60W',550.00,'https://placehold.co/400x400/png?text=Desk+60+White','2026-02-20 14:09:31'),(29,14,'48x24','PRP-TBL-SS-001-48X',285.00,NULL,'2026-03-19 17:58:53'),(30,14,'60x24','PRP-TBL-SS-001-60X',285.00,NULL,'2026-03-19 17:58:55'),(31,14,'72x30','PRP-TBL-SS-001-72X',285.00,NULL,'2026-03-19 17:58:56'),(32,15,'8 bottles - 6 bottles - 15 bottles','btl-hLD-SS-001-8 B-6 B-15 ',0.00,NULL,'2026-03-19 21:33:42'),(33,16,'48 Inch','HDR-5000-48 ',200.00,NULL,'2026-03-20 17:25:01'),(34,16,'60 Inch','HDR-5000-60 ',210.00,NULL,'2026-03-20 17:25:02'),(35,16,'72 Inch','HDR-5000-72 ',190.00,NULL,'2026-03-20 17:25:02'),(42,18,'50 Inch - industrial black','HDR-5000-2-50 -IND',300.00,NULL,'2026-03-20 20:01:46'),(43,18,'50 Inch - white','HDR-5000-2-50 -WHI',300.00,NULL,'2026-03-20 20:01:48'),(44,18,'62 Inch - industrial black','HDR-5000-2-62 -IND',300.00,NULL,'2026-03-20 20:01:56'),(45,18,'62 Inch - white','HDR-5000-2-62 -WHI',300.00,NULL,'2026-03-20 20:01:59'),(46,18,'74 Inch - industrial black','HDR-5000-2-74 -IND',300.00,NULL,'2026-03-20 20:02:05'),(47,18,'74 Inch - white','HDR-5000-2-74 -WHI',300.00,NULL,'2026-03-20 20:02:06'),(49,20,'50 inch','HDR-5000-3-50 ',500.00,NULL,'2026-03-20 20:53:19'),(50,20,'20 inch','HDR-5000-3-20 ',600.00,NULL,'2026-03-20 20:54:07'),(51,21,'48 Inch','HDR-5000-4-48 ',300.00,NULL,'2026-03-20 21:43:51'),(52,21,'60 Inch','HDR-5000-4-60 ',300.00,NULL,'2026-03-20 21:43:52'),(53,21,'72 Inch','HDR-5000-4-72 ',300.00,NULL,'2026-03-20 21:43:53'),(54,23,'Fragrance-Free','ECO-SAN-1G-FRA',45.00,NULL,'2026-03-23 16:48:59'),(55,23,'Citrus Breeze','ECO-SAN-1G-CIT',48.00,NULL,'2026-03-23 16:49:01'),(56,23,'Rose-Lilly mash','ECO-SAN-1G-ROS',46.00,NULL,'2026-03-23 16:49:03'),(57,25,'Fragrance-Free','ECO-SAN-1G-FRA',200.00,NULL,'2026-03-23 20:59:43'),(58,25,'Citrus Breeze','ECO-SAN-1G-CIT',200.00,NULL,'2026-03-23 20:59:45'),(59,30,'Small','MEW MEW -SMA',22.00,NULL,'2026-04-08 20:28:00'),(60,30,'medium','MEW MEW -MED',22.00,NULL,'2026-04-08 20:28:00'),(61,30,'Large','MEW MEW -LAR',22.00,NULL,'2026-04-08 20:28:00'),(62,32,'Size - Small','APR-200-S',24.99,NULL,'2026-04-13 15:03:20'),(63,32,'Size - Large','APR-200-L',26.99,NULL,'2026-04-13 15:03:20');
/*!40000 ALTER TABLE `sku_variant` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sku_variant_attributes`
--

DROP TABLE IF EXISTS `sku_variant_attributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sku_variant_attributes` (
  `variant_id` bigint NOT NULL,
  `value_id` bigint NOT NULL,
  PRIMARY KEY (`variant_id`,`value_id`),
  KEY `value_id` (`value_id`),
  CONSTRAINT `sku_variant_attributes_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `sku_variant` (`variant_id`) ON DELETE CASCADE,
  CONSTRAINT `sku_variant_attributes_ibfk_2` FOREIGN KEY (`value_id`) REFERENCES `sku_attribute_values` (`value_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sku_variant_attributes`
--

LOCK TABLES `sku_variant_attributes` WRITE;
/*!40000 ALTER TABLE `sku_variant_attributes` DISABLE KEYS */;
INSERT INTO `sku_variant_attributes` VALUES (1,1),(3,1),(4,2),(2,3),(3,4),(4,5),(29,30),(30,31),(31,32),(49,33),(50,34),(51,35),(52,36),(53,37),(54,38),(57,38),(55,39),(58,39),(56,40);
/*!40000 ALTER TABLE `sku_variant_attributes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sku_volume_pricing`
--

DROP TABLE IF EXISTS `sku_volume_pricing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sku_volume_pricing` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `sku_id` bigint NOT NULL,
  `min_quantity` int NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `sku_id` (`sku_id`),
  CONSTRAINT `sku_volume_pricing_ibfk_1` FOREIGN KEY (`sku_id`) REFERENCES `sku_master` (`sku_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sku_volume_pricing`
--

LOCK TABLES `sku_volume_pricing` WRITE;
/*!40000 ALTER TABLE `sku_volume_pricing` DISABLE KEYS */;
INSERT INTO `sku_volume_pricing` VALUES (17,14,10,270.00,'2026-03-19 17:58:52'),(18,14,15,350.00,'2026-03-19 17:58:52'),(19,16,10,900.00,'2026-03-20 17:25:00'),(20,16,8,700.00,'2026-03-20 17:25:00'),(22,23,50,35.00,'2026-03-23 16:48:58'),(23,29,10,20.00,'2026-04-03 12:44:47'),(35,30,10,11.00,'2026-04-08 20:28:42'),(36,30,15,13.00,'2026-04-08 20:28:42');
/*!40000 ALTER TABLE `sku_volume_pricing` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sp_debug_log`
--

DROP TABLE IF EXISTS `sp_debug_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sp_debug_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `step` varchar(100) DEFAULT NULL,
  `message` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sp_debug_log`
--

LOCK TABLES `sp_debug_log` WRITE;
/*!40000 ALTER TABLE `sp_debug_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `sp_debug_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_notifications`
--

DROP TABLE IF EXISTS `stock_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stock_notifications` (
  `notification_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `product_id` int NOT NULL,
  `variant_id` bigint DEFAULT NULL,
  `is_notified` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notification_id`),
  KEY `product_id` (`product_id`),
  KEY `variant_id` (`variant_id`),
  CONSTRAINT `stock_notifications_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE,
  CONSTRAINT `stock_notifications_ibfk_2` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`variant_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_notifications`
--

LOCK TABLES `stock_notifications` WRITE;
/*!40000 ALTER TABLE `stock_notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `stock_notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `store_inventory`
--

DROP TABLE IF EXISTS `store_inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `store_inventory` (
  `inventory_id` bigint NOT NULL AUTO_INCREMENT,
  `store_id` int NOT NULL,
  `product_id` int NOT NULL,
  `variant_id` bigint DEFAULT NULL,
  `quantity` int DEFAULT '0',
  `low_stock_threshold` int DEFAULT '5',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`inventory_id`),
  UNIQUE KEY `uk_store_product_variant` (`store_id`,`product_id`,`variant_id`),
  KEY `fk_inv_store` (`store_id`),
  KEY `fk_inv_prod` (`product_id`),
  KEY `fk_inv_var` (`variant_id`),
  CONSTRAINT `fk_inv_prod` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_inv_store` FOREIGN KEY (`store_id`) REFERENCES `stores` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_inv_var` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`variant_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `store_inventory`
--

LOCK TABLES `store_inventory` WRITE;
/*!40000 ALTER TABLE `store_inventory` DISABLE KEYS */;
/*!40000 ALTER TABLE `store_inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stores`
--

DROP TABLE IF EXISTS `stores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stores` (
  `store_id` int NOT NULL AUTO_INCREMENT,
  `area_id` int NOT NULL,
  `name` varchar(150) NOT NULL,
  `store_code` varchar(50) DEFAULT NULL,
  `address` text,
  `is_active` tinyint(1) DEFAULT '1',
  `min_order_value` decimal(10,2) DEFAULT '0.00' COMMENT 'Minimum cart value required to checkout',
  `max_order_value` decimal(10,2) DEFAULT NULL COMMENT 'Maximum order value allowed',
  `approval_threshold` decimal(10,2) DEFAULT NULL COMMENT 'Orders above this amount require manager approval',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`store_id`),
  UNIQUE KEY `store_code` (`store_code`),
  KEY `fk_store_area` (`area_id`),
  CONSTRAINT `fk_store_area` FOREIGN KEY (`area_id`) REFERENCES `areas` (`area_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stores`
--

LOCK TABLES `stores` WRITE;
/*!40000 ALTER TABLE `stores` DISABLE KEYS */;
INSERT INTO `stores` VALUES (1,1,'Manhattan Distribution Center','NY-MHT-01','350 5th Ave, NY',1,0.00,50000.00,5000.00,'2026-02-19 19:01:37'),(2,1,'Brooklyn Local Depot','NY-BKL-02','445 Albee Sq, Brooklyn',1,200.00,15000.00,2000.00,'2026-02-19 19:01:37'),(3,2,'Los Angeles Fulfillment','CA-LAX-01','1 World Way, LA',1,500.00,30000.00,5000.00,'2026-02-19 19:01:37'),(4,3,'Austin Tech Hub','TX-AUS-01','1100 Congress Ave, Austin',1,0.00,10000.00,1000.00,'2026-02-19 19:01:37'),(5,2,'Sacramento Hub','CA-SCR-01',NULL,1,1000.00,999999.99,3000.00,'2026-03-25 18:42:44');
/*!40000 ALTER TABLE `stores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_addresses`
--

DROP TABLE IF EXISTS `user_addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_addresses` (
  `address_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `address_type` varchar(50) DEFAULT NULL,
  `address_line1` varchar(255) NOT NULL,
  `address_line2` varchar(255) DEFAULT NULL,
  `city` varchar(100) NOT NULL,
  `state` varchar(100) DEFAULT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `country` varchar(100) NOT NULL,
  `is_default` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `user_addresses_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_addresses`
--

LOCK TABLES `user_addresses` WRITE;
/*!40000 ALTER TABLE `user_addresses` DISABLE KEYS */;
INSERT INTO `user_addresses` VALUES (1,1,'Shipping','595 Market','St San Francisco','San Fransico','CA','94105','United States',0,'2026-02-24 00:48:05'),(2,1,'Billing','595 Market','St San Francisco','San Fransico','CA','94105','United States',0,'2026-02-24 00:48:12'),(3,1,'Shipping','255/5 Market','St San diego','San diego','CA','87106','United States',0,'2026-02-27 14:14:03'),(4,12,'Shipping','80/1A SL Das Lane Hooghly','','Kolkata','West Bengal','713301','India',0,'2026-03-27 17:42:39'),(5,12,'Billing','80/1A SL Das Lane Hooghly','80/1A SL Das Lane Hooghly','Kolkata','West Bengal','713301','India',0,'2026-03-27 17:42:47'),(6,13,'Shipping','80/1A SL Das Lane Hooghly','80/1A SL Das Lane Hooghly','Kolkata','West Bengal','713301','India',0,'2026-03-27 18:41:38'),(7,13,'Shipping','80/1A SL Das Lane Hooghly','','Kolkata','West Bengal','713301','India',0,'2026-03-27 18:41:44'),(8,13,'Billing','81/1A SL Das Lane Hooghly','','Kolkata','West Bengal','713301','India',0,'2026-03-27 18:41:53'),(9,14,'Shipping','81/1A SL Das Lane Hooghly','','Kolkata','West Bengal','713301','India',0,'2026-03-27 20:01:31'),(10,14,'Billing','86/1A SL Das Lane Hooghly','','Kolkata','West Bengal','713301','India',0,'2026-03-27 20:01:43'),(11,1,'Shipping','86/1A SL Das Lane Hooghly','','Kolkata','West Bengal','713301','India',0,'2026-04-01 02:35:19');
/*!40000 ALTER TABLE `user_addresses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_favorite_products`
--

DROP TABLE IF EXISTS `user_favorite_products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_favorite_products` (
  `user_id` bigint NOT NULL,
  `product_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`,`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_favorite_products`
--

LOCK TABLES `user_favorite_products` WRITE;
/*!40000 ALTER TABLE `user_favorite_products` DISABLE KEYS */;
INSERT INTO `user_favorite_products` VALUES (12,1,'2026-04-13 20:38:55'),(12,2,'2026-04-13 21:04:31'),(12,23,'2026-04-15 16:12:20');
/*!40000 ALTER TABLE `user_favorite_products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_restaurant_mapping`
--

DROP TABLE IF EXISTS `user_restaurant_mapping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_restaurant_mapping` (
  `mapping_id` int NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `restaurant_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`mapping_id`),
  UNIQUE KEY `uk_user_restaurant` (`user_id`,`restaurant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_restaurant_mapping`
--

LOCK TABLES `user_restaurant_mapping` WRITE;
/*!40000 ALTER TABLE `user_restaurant_mapping` DISABLE KEYS */;
INSERT INTO `user_restaurant_mapping` VALUES (2,14,2,'2026-03-30 10:37:09'),(3,13,2,'2026-04-09 09:54:53'),(5,5,1,'2026-04-09 09:55:13'),(6,1,2,'2026-04-09 17:17:16'),(7,2,1,'2026-04-09 17:17:24'),(8,15,5,'2026-04-16 14:35:41'),(9,12,4,'2026-04-16 15:06:24');
/*!40000 ALTER TABLE `user_restaurant_mapping` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_store_access`
--

DROP TABLE IF EXISTS `user_store_access`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_store_access` (
  `access_id` int NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `store_id` int NOT NULL,
  `role` enum('customer','store_manager','regional_manager') DEFAULT 'customer',
  PRIMARY KEY (`access_id`),
  UNIQUE KEY `uk_user_store` (`user_id`,`store_id`),
  KEY `fk_access_store` (`store_id`),
  CONSTRAINT `fk_access_store` FOREIGN KEY (`store_id`) REFERENCES `stores` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_access_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_store_access`
--

LOCK TABLES `user_store_access` WRITE;
/*!40000 ALTER TABLE `user_store_access` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_store_access` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_store_mapping`
--

DROP TABLE IF EXISTS `user_store_mapping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_store_mapping` (
  `mapping_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `store_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`mapping_id`),
  UNIQUE KEY `uk_user_store` (`user_id`,`store_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_store_mapping`
--

LOCK TABLES `user_store_mapping` WRITE;
/*!40000 ALTER TABLE `user_store_mapping` DISABLE KEYS */;
INSERT INTO `user_store_mapping` VALUES (1,16,4,'2026-04-04 21:57:41'),(2,9,1,'2026-04-04 22:02:35'),(3,8,1,'2026-04-04 22:02:48'),(4,7,1,'2026-04-04 22:03:02'),(5,6,1,'2026-04-04 22:03:19'),(6,17,4,'2026-04-07 08:21:38'),(7,18,5,'2026-04-09 17:06:06'),(9,19,2,'2026-04-09 17:07:08'),(10,20,5,'2026-04-17 15:30:40');
/*!40000 ALTER TABLE `user_store_mapping` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` bigint NOT NULL AUTO_INCREMENT,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `user_type` enum('restaurant','warehouse','warehouse_manager','warehouse_worker','helpdesk','billing') NOT NULL DEFAULT 'restaurant',
  `assigned_store_id` int DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`),
  KEY `fk_user_assigned_store` (`assigned_store_id`),
  CONSTRAINT `fk_user_assigned_store` FOREIGN KEY (`assigned_store_id`) REFERENCES `stores` (`store_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Pratip','Chakraborty','pratip109new@gmail.com','scrypt:32768:8:1$ALZZsnPb6tOWA9k7$83694f359a0326370c15d8c777110f41a832f592ed165976dcf9a8fab92b886d5bb1ea44c22d1b12a1106d9fea98a370307e0ff45f8fc4f7e588f68f562d222c','9674436120',1,'2026-01-20 22:47:44','2026-02-03 02:24:53','restaurant',NULL),(2,'Sara','Tella','pratipchak@gmail.com','scrypt:32768:8:1$PqzU8baPJeoxFFdF$d19767d1ac60136e309b2fd907e51b7ae4002720bfe39b3d31bac468c9a6df6908f75b951fcdff7432b5f27c955f5d4ec293ac5bd6bdf8408086b013efd92ab8','',1,'2026-01-22 18:34:36','2026-01-22 18:34:36','restaurant',NULL),(3,'P','C','pratipc10@gmail.com','scrypt:32768:8:1$QVZ0RWA9UCCpWJas$4b1c9243b56c9aeb29e74168285e270a6cabc31359196574f8cd33be270408d9285be6ddc21cde866ac42b5114103e4240614325adf4c4db5013a9713b4acf35','09051325674',1,'2026-01-28 18:53:36','2026-01-28 18:53:36','restaurant',NULL),(4,'Sikar','Das','srikar@gmail.com','scrypt:32768:8:1$3v2Sc3Ty3WVSAdtY$7602e1491b63192d8ea3b535bdf339f3e0c7f4def4f74ff15f5d935e78e11c92c284f411b404a80a28e67076e65bce3d867e26d0a5e28d37edcf49b0e0f1bc54','',1,'2026-01-28 21:22:13','2026-01-28 21:22:13','restaurant',NULL),(5,'Pratip','Chakraborty','pratip109@outlook.com','scrypt:32768:8:1$Mul5q7S7Yzc6UrPp$d66fe77b9d844484d3c93b874594f798c536e4f083b4381c7883f292c98c079b2f0d1767b26496ec313c7fed0ab715a26572eb6ffdb9561ef392734242044fbe','9051325674',1,'2026-02-10 01:02:01','2026-02-10 01:02:01','restaurant',NULL),(6,'John','Warehouse','warehouse@saratella.com','scrypt:32768:8:1$ALZZsnPb6tOWA9k7$83694f359a0326370c15d8c777110f41a832f592ed165976dcf9a8fab92b886d5bb1ea44c22d1b12a1106d9fea98a370307e0ff45f8fc4f7e588f68f562d222c','555-0000',1,'2026-02-26 21:00:48','2026-03-05 15:03:01','warehouse_manager',1),(7,'Mike','Packer','worker@saratella.com','scrypt:32768:8:1$ALZZsnPb6tOWA9k7$83694f359a0326370c15d8c777110f41a832f592ed165976dcf9a8fab92b886d5bb1ea44c22d1b12a1106d9fea98a370307e0ff45f8fc4f7e588f68f562d222c','555-1111',1,'2026-03-05 15:03:01','2026-03-05 15:03:01','warehouse_worker',1),(8,'Jack 2','Worker','worker@warehouse.com','scrypt:32768:8:1$ap9KvUue5iomRHmn$7528c67cf79fe4cd3536ca32bd86e131adf290ce9a970892bcac9eeeb8a96d84fbaa618c30e984917b359b82e403b6df9030d3dbf13d80a593111af02027ebd2','123456789',1,'2026-03-05 23:41:03','2026-03-06 18:36:20','warehouse_worker',1),(9,'Jason','Worker','worker2@warehouse.com','scrypt:32768:8:1$HiIQNMVe1VX3KGki$5c4fa1157411bdf778c5642bee13097cd5b806721e5d62922ca45d0567236f6be679d62cb931c5d73c887c510556aa29892e7bfa4c76c2c4967a17acd0b321a6','09051310937',1,'2026-03-07 18:13:56','2026-03-07 18:14:18','warehouse_worker',1),(10,'Saratella','LLC','majid@saratella.com','scrypt:32768:8:1$x0Iwl7EsaxhLw5zM$71ba2e75249628ba3d78cceedf386c30503aba1cdc6c5d481210e2fe96f9ae70d773d3ee40cacbd555af04315385359f2367c9b483754852a7c380f328e7a9c6','9874897590',1,'2026-03-17 01:11:56','2026-03-17 01:34:00','helpdesk',NULL),(11,'Baishakhi','Karmakar','baishakhi@saratella.com','scrypt:32768:8:1$Rmr3U4TF1E2QUYYA$b7cae4c3c7983595235c8d950c2f89f1a8e6fcf80aae65346900697767f34d8f538d964162f3b8214236d70a7635d12fcbe43d55ca3f1c10508ebe2a9862d0c2','',1,'2026-03-26 19:51:54','2026-03-26 19:52:23','helpdesk',NULL),(12,'Aman','Kumar','Aman@saratella.com','scrypt:32768:8:1$dSD5ZEZYTchezcY9$c891f58cb6d3d300e726ee39f684f6f7c978d4ea1a071450d6e4369662990815ff96ccbbb97bcdf0a74676ffe35e8d30de44175214164a266a9e6640d484bc00','',1,'2026-03-27 17:42:30','2026-03-27 17:42:30','restaurant',NULL),(13,'Udit','Das','udit@gmail.com','scrypt:32768:8:1$8uJYva1EsltDS2nu$c0c3740cb67b6eb8d68686410bb46daaf98d089b6a355ed746c03e101de5ec8e26a5477bf1e8dd82ae826490db8b67f057d0f988f7d3f90b41bc17d9d1b32897','',1,'2026-03-27 18:41:19','2026-03-27 18:41:19','restaurant',NULL),(14,'Pratip','C','pratip10@gmail.com','scrypt:32768:8:1$6eqjzxi6GYQElbMZ$ef32e21cb0a96cf3f01e1cbe7a85829b70c3bf820f547d2bb23561eba6e99a0e91a63b90b4fc8a7f40e5121f4af678cbb677c38b80d51589299dc50f8af3e448','',1,'2026-03-27 19:57:44','2026-03-27 19:57:44','restaurant',NULL),(15,'Suraj','Chandra','surajchandra@gmail.com','scrypt:32768:8:1$5NJNJ3mUoJ4vgrjI$091d607b5ce07ee1e01ab189585d7fc74e76fb899a92ef6b482ef2ff742a3ff3c6b39691b6128f53f2b0a763093eb793cc2d5a962b442fbe3b5c50d1d36359de',NULL,1,'2026-03-30 16:06:55','2026-03-30 16:06:55','restaurant',NULL),(16,'James','Philip','warehouse2@saratella.com','scrypt:32768:8:1$djv1smS4ezLx8MyR$5f09a744739e2922f366250d810065922891ad7b1c3f3d33575ae3ddccc8200395bab4a6ba43f4b8e3ceb732836210c8837041ea1fed1176f05e87f88607e5bf',NULL,1,'2026-04-04 21:31:29','2026-04-04 21:31:29','warehouse_manager',NULL),(17,'Jones','Picker','jones@gmail.com','scrypt:32768:8:1$EcZTktYIGH1pUXCX$5b97596e9a4a242c5278c7231ff548006991c1c0da22fcd36eb9920ec4b4ff44129a1aa6e900fd41b8953a5d5fb95ca24c1d1a20173bd79f4b442f3b254cd52e',NULL,1,'2026-04-07 13:51:38','2026-04-07 13:51:38','warehouse_worker',NULL),(18,'Cassie','Edwards','warehouse3@saratella.com','scrypt:32768:8:1$oAB8yQXbqhmS97Hy$8f1ef904f647e06f027c39903268351164ab19e0d5442b4db79cac9d9fab802b6d7673e524cfb35840e40040dcf3fca63dabca3f4c6704eaa65f6585b1448310',NULL,1,'2026-04-09 22:36:06','2026-04-09 22:36:06','warehouse_manager',NULL),(19,'Jaspreet','Singh','warehouse4@saratella.com','scrypt:32768:8:1$7V19blz8s2nDTGgH$808350b499eff9b7b9c739bda8cc00c8df5644083a03c637e2331763efcebcae873cff3e8ce9aec4162479253e4b3831b40453059bd88e0ebc6b68875aec221c',NULL,1,'2026-04-09 22:36:53','2026-04-09 22:36:53','warehouse_manager',NULL),(20,'issac','williams','issac@worker.com','scrypt:32768:8:1$S4FIm5ajcVa7Ix79$f63f7e75782f4c14c9acae99a33a538f78ffe24f520f7dbd59ca1825e733acd09eadfa1241ac240a4786889acef26845ce4fca89c5dd2c206d0f9a0b0910a1a9','',1,'2026-04-17 21:00:40','2026-04-17 21:00:40','warehouse_worker',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `variant_attribute_values`
--

DROP TABLE IF EXISTS `variant_attribute_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `variant_attribute_values` (
  `variant_id` bigint NOT NULL,
  `attribute_value_id` int NOT NULL,
  PRIMARY KEY (`variant_id`,`attribute_value_id`),
  KEY `attribute_value_id` (`attribute_value_id`),
  CONSTRAINT `variant_attribute_values_ibfk_1` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`variant_id`) ON DELETE CASCADE,
  CONSTRAINT `variant_attribute_values_ibfk_2` FOREIGN KEY (`attribute_value_id`) REFERENCES `attribute_values` (`value_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `variant_attribute_values`
--

LOCK TABLES `variant_attribute_values` WRITE;
/*!40000 ALTER TABLE `variant_attribute_values` DISABLE KEYS */;
/*!40000 ALTER TABLE `variant_attribute_values` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'ecommerce_db'
--

--
-- Dumping routines for database 'ecommerce_db'
--
/*!50003 DROP PROCEDURE IF EXISTS `AddAddress` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddAddress`(
    IN p_user_id INT,
    IN p_address_type VARCHAR(50), -- Can now be NULL`user_addresses`
    IN p_line1 VARCHAR(255),
    IN p_line2 VARCHAR(255),
    IN p_city VARCHAR(100),
    IN p_state VARCHAR(100),
    IN p_postal_code VARCHAR(20),
    IN p_country VARCHAR(100)
)
BEGIN
    INSERT INTO user_addresses (user_id, address_type, address_line1, address_line2, city, state, postal_code, country)
    VALUES (p_user_id, p_address_type, p_line1, p_line2, p_city, p_state, p_postal_code, p_country);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddProductMedia` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddProductMedia`(
    IN p_sku_id BIGINT, IN p_variant_id BIGINT, 
    IN p_media_url VARCHAR(255), IN p_media_type VARCHAR(50), IN p_is_primary TINYINT
)
BEGIN
    INSERT INTO sku_media (sku_id, variant_id, media_url, media_type, is_primary)
    VALUES (p_sku_id, p_variant_id, p_media_url, p_media_type, p_is_primary);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddProductMediaByCombo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddProductMediaByCombo`(
    IN p_sku_id BIGINT,
    IN p_combo_key VARCHAR(255),
    IN p_media_url VARCHAR(255),
    IN p_media_type VARCHAR(50),
    IN p_is_primary TINYINT
)
BEGIN
    DECLARE v_variant_id BIGINT DEFAULT NULL;
    
    -- If a combination key is provided, try to securely find the specific variant ID
    IF p_combo_key IS NOT NULL AND p_combo_key != '' THEN
        SELECT variant_id INTO v_variant_id 
        FROM sku_variant 
        WHERE sku_id = p_sku_id AND combination_key = p_combo_key 
        LIMIT 1;
    END IF;
    
    -- Insert the media. 
    -- If the variant was found, it attaches to the variant.
    -- If the variant was NOT found (or product has no variants), it attaches safely to the base product!
    INSERT INTO sku_media (sku_id, variant_id, media_url, media_type, is_primary)
    VALUES (p_sku_id, v_variant_id, p_media_url, p_media_type, p_is_primary);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddToCart` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddToCart`(
    IN p_user_id BIGINT,
    IN p_session_id VARCHAR(255),
    IN p_product_id INT,
    IN p_variant_id INT,
    IN p_quantity INT,
    IN p_price DECIMAL(10,2)
)
BEGIN
    DECLARE v_cart_id INT;

    -- Find active cart
    SELECT cart_id INTO v_cart_id
    FROM carts
    WHERE status = 'active'
      AND ((p_user_id IS NOT NULL AND user_id = p_user_id)
           OR (p_user_id IS NULL AND session_id = p_session_id))
    LIMIT 1;

    -- Create if not exists (omitting store_id entirely)
    IF v_cart_id IS NULL THEN
        INSERT INTO carts (user_id, session_id, status)
        VALUES (p_user_id, p_session_id, 'active');
        SET v_cart_id = LAST_INSERT_ID();
    END IF;

    -- Upsert Cart Item
    IF EXISTS (SELECT 1 FROM cart_items WHERE cart_id = v_cart_id AND product_id = p_product_id AND (variant_id = p_variant_id OR (variant_id IS NULL AND p_variant_id IS NULL))) THEN
        UPDATE cart_items
        SET quantity = quantity + p_quantity, price = p_price
        WHERE cart_id = v_cart_id AND product_id = p_product_id AND (variant_id = p_variant_id OR (variant_id IS NULL AND p_variant_id IS NULL));
    ELSE
        INSERT INTO cart_items (cart_id, product_id, variant_id, quantity, price)
        VALUES (v_cart_id, p_product_id, p_variant_id, p_quantity, p_price);
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddUserAddress` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddUserAddress`(
    IN p_user_id INT,
    IN p_type VARCHAR(50),
    IN p_line1 VARCHAR(255),
    IN p_line2 VARCHAR(255),
    IN p_city VARCHAR(100),
    IN p_state VARCHAR(100),
    IN p_zip VARCHAR(20),
    IN p_country VARCHAR(100)
)
BEGIN
    INSERT INTO user_addresses (user_id, address_type, address_line1, address_line2, city, state, postal_code, country)
    VALUES (p_user_id, p_type, p_line1, p_line2, p_city, p_state, p_zip, p_country);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddVariantAttribute` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddVariantAttribute`(
    IN p_variant_id BIGINT,
    IN p_attr_name VARCHAR(100),
    IN p_attr_value VARCHAR(100)
)
BEGIN
    DECLARE v_attr_id BIGINT;
    DECLARE v_val_id BIGINT;

    -- Step A: Get or Create Attribute Header (e.g., 'Size')
    SELECT attribute_id INTO v_attr_id FROM sku_attributes WHERE attribute_name = p_attr_name LIMIT 1;
    IF v_attr_id IS NULL THEN
        INSERT INTO sku_attributes (attribute_name) VALUES (p_attr_name);
        SET v_attr_id = LAST_INSERT_ID();
    END IF;

    -- Step B: Get or Create Attribute Value (e.g., 'Large')
    SELECT value_id INTO v_val_id FROM sku_attribute_values WHERE attribute_id = v_attr_id AND attribute_value = p_attr_value LIMIT 1;
    IF v_val_id IS NULL THEN
        INSERT INTO sku_attribute_values (attribute_id, attribute_value) VALUES (v_attr_id, p_attr_value);
        SET v_val_id = LAST_INSERT_ID();
    END IF;

    -- Step C: Map Variant to the specific Attribute Value
    INSERT IGNORE INTO sku_variant_attributes (variant_id, value_id) 
    VALUES (p_variant_id, v_val_id);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddWarehouseWorker` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddWarehouseWorker`(IN p_manager_id BIGINT, IN p_first VARCHAR(100), IN p_last VARCHAR(100), IN p_email VARCHAR(255), IN p_phone VARCHAR(50), IN p_pw VARCHAR(255))
BEGIN
    DECLARE v_store_id INT;
    DECLARE v_new_user_id BIGINT;
    DECLARE v_exists INT;
    
    SELECT store_id INTO v_store_id FROM user_store_mapping WHERE user_id = p_manager_id LIMIT 1;
    SELECT COUNT(*) INTO v_exists FROM users WHERE email = p_email;
    
    IF v_exists > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A user with this email already exists.';
    ELSEIF v_store_id IS NOT NULL THEN
        INSERT INTO users (first_name, last_name, email, phone, password_hash, user_type, is_active)
        VALUES (p_first, p_last, p_email, p_phone, p_pw, 'warehouse_worker', 1);
        SET v_new_user_id = LAST_INSERT_ID();
        
        INSERT INTO user_store_mapping (user_id, store_id) VALUES (v_new_user_id, v_store_id);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Manager not assigned to a store.';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AdminForceUpdateOrderStatus` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AdminForceUpdateOrderStatus`(
    IN p_order_id BIGINT,
    IN p_new_status VARCHAR(50),
    IN p_admin_id BIGINT
)
BEGIN
    -- 1. Update the Global Order Header
    UPDATE orders 
    SET order_status = p_new_status,
        updated_at = CURRENT_TIMESTAMP
    WHERE order_id = p_order_id;

    -- 2. SMART DOM SYNC: If this order was already routed to warehouses, 
    -- we must sync their local allocations so workers don't keep packing a cancelled/shipped order!
    IF p_new_status IN ('cancelled', 'shipped', 'delivered') THEN
        UPDATE order_allocations
        SET status = p_new_status
        WHERE order_id = p_order_id 
          AND status NOT IN ('shipped', 'delivered', 'cancelled');
    END IF;
    
    -- Note: We capture p_admin_id in the parameters so in the future 
    -- you can easily add an `audit_logs` table insert here to track who forced the change!
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AllocateOrderItem` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AllocateOrderItem`(
    IN p_order_id BIGINT, 
    IN p_order_item_id BIGINT, 
    IN p_store_id INT, 
    IN p_qty INT
)
BEGIN
    -- Record the routing decision
    INSERT INTO order_allocations (order_id, order_item_id, store_id, allocated_qty)
    VALUES (p_order_id, p_order_item_id, p_store_id, p_qty);

    -- DEDUCT PHYSICAL INVENTORY from the selected warehouse
    UPDATE sku_inventory
    SET quantity = quantity - p_qty
    WHERE store_id = p_store_id 
      AND sku_id = (SELECT product_id FROM order_items WHERE order_item_id = p_order_item_id)
      AND variant_id <=> (SELECT variant_id FROM order_items WHERE order_item_id = p_order_item_id);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AssignWarehouseWorker` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AssignWarehouseWorker`(IN p_order_id BIGINT, IN p_target_worker_id BIGINT, IN p_action_user_id BIGINT)
BEGIN
    DECLARE v_store_id INT;
    SELECT store_id INTO v_store_id FROM user_store_mapping WHERE user_id = p_action_user_id LIMIT 1;
    
    IF v_store_id IS NOT NULL THEN
        UPDATE order_allocations SET assigned_worker_id = p_target_worker_id, status = 'picking'
        WHERE order_id = p_order_id AND store_id = v_store_id;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `BulkImportProduct` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `BulkImportProduct`(
    IN p_name VARCHAR(255), 
    IN p_sku VARCHAR(100), 
    IN p_price DECIMAL(10,2),
    IN p_old_price DECIMAL(10,2), 
    IN p_cost DECIMAL(10,2),
    IN p_category VARCHAR(100), 
    IN p_brand VARCHAR(100),
    IN p_gtin VARCHAR(100), 
    IN p_mpn VARCHAR(100),
    IN p_weight DECIMAL(10,2), 
    IN p_length DECIMAL(10,2), 
    IN p_width DECIMAL(10,2), 
    IN p_height DECIMAL(10,2),
    IN p_case_pack INT, 
    IN p_min_cart INT, 
    IN p_max_cart INT,
    IN p_non_returnable TINYINT, 
    IN p_disable_buy TINYINT, 
    IN p_call_price TINYINT,
    IN p_desc TEXT, 
    IN p_full_desc TEXT, 
    IN p_admin_comment TEXT,
    IN p_specs TEXT,
    IN p_warranty TEXT,
    IN p_mfg_info TEXT,
    IN p_active TINYINT
)
BEGIN
    DECLARE v_cat_id INT DEFAULT NULL;
    DECLARE v_brand_id INT DEFAULT NULL;
    DECLARE v_sku_id BIGINT;

    -- 1. Auto-Resolve or Create Category
    IF p_category IS NOT NULL AND p_category != '' THEN
        SELECT category_id INTO v_cat_id FROM categories WHERE name = p_category LIMIT 1;
        IF v_cat_id IS NULL THEN
            INSERT INTO categories (name) VALUES (p_category);
            SET v_cat_id = LAST_INSERT_ID();
        END IF;
    END IF;

    -- 2. Auto-Resolve or Create Brand
    IF p_brand IS NOT NULL AND p_brand != '' THEN
        SELECT brand_id INTO v_brand_id FROM brands WHERE name = p_brand LIMIT 1;
        IF v_brand_id IS NULL THEN
            INSERT INTO brands (name) VALUES (p_brand);
            SET v_brand_id = LAST_INSERT_ID();
        END IF;
    END IF;

    -- 3. Check if SKU already exists
    SELECT sku_id INTO v_sku_id FROM sku_master WHERE sku = p_sku LIMIT 1;

    -- 4. Upsert Product Logic
    IF v_sku_id IS NOT NULL THEN
        -- Product exists, UPDATE it!
        UPDATE sku_master SET
            name = p_name, price = p_price, old_price = p_old_price, product_cost = p_cost,
            category_id = v_cat_id, brand_id = v_brand_id, gtin = p_gtin, manufacturer_part_number = p_mpn,
            weight = p_weight, length = p_length, width = p_width, height = p_height,
            case_pack_quantity = p_case_pack, minimum_cart_qty = p_min_cart, maximum_cart_qty = p_max_cart,
            not_returnable = p_non_returnable, disable_buy_button = p_disable_buy, call_for_price = p_call_price,
            description = p_desc, product_definition = p_full_desc, admin_comment = p_admin_comment,
            specifications = p_specs, warranty_info = p_warranty, manufacturer_info = p_mfg_info,
            is_active = p_active, updated_at = CURRENT_TIMESTAMP
        WHERE sku_id = v_sku_id;
    ELSE
        -- New Product, INSERT it!
        INSERT INTO sku_master (
            name, sku, price, old_price, product_cost, category_id, brand_id, 
            gtin, manufacturer_part_number, weight, length, width, height, 
            case_pack_quantity, minimum_cart_qty, maximum_cart_qty,
            not_returnable, disable_buy_button, call_for_price, 
            description, product_definition, admin_comment, specifications, warranty_info, manufacturer_info, is_active
        ) VALUES (
            p_name, p_sku, p_price, p_old_price, p_cost, v_cat_id, v_brand_id, 
            p_gtin, p_mpn, p_weight, p_length, p_width, p_height, 
            p_case_pack, p_min_cart, p_max_cart,
            p_non_returnable, p_disable_buy, p_call_price, 
            p_desc, p_full_desc, p_admin_comment, p_specs, p_warranty, p_mfg_info, p_active
        );
        SET v_sku_id = LAST_INSERT_ID();
    END IF;
    
    -- Return the ID so Python knows which base product to attach variants & images to!
    SELECT v_sku_id AS new_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `BulkReleaseOrders` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `BulkReleaseOrders`(IN p_manager_id BIGINT, IN p_order_ids_json JSON)
BEGIN
    DECLARE v_store_id INT;
    DECLARE i INT DEFAULT 0;
    DECLARE v_count INT;
    DECLARE v_order_id BIGINT;
    
    SELECT store_id INTO v_store_id FROM user_store_mapping WHERE user_id = p_manager_id LIMIT 1;
    
    IF v_store_id IS NOT NULL THEN
        SET v_count = JSON_LENGTH(p_order_ids_json);
        WHILE i < v_count DO
            SET v_order_id = JSON_UNQUOTE(JSON_EXTRACT(p_order_ids_json, CONCAT('$[', i, ']')));
            UPDATE order_allocations SET assigned_worker_id = 0, status = 'released_to_floor'
            WHERE order_id = v_order_id AND store_id = v_store_id AND assigned_worker_id IS NULL;
            SET i = i + 1;
        END WHILE;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CartAddItem` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CartAddItem`(
    IN p_user_id BIGINT,
    IN p_session_id VARCHAR(255),
    IN p_product_id BIGINT,
    IN p_quantity INT,
    IN p_price DECIMAL(10,2),
    IN p_variant_id BIGINT -- New Parameter
)
BEGIN
    DECLARE v_cart_id BIGINT;

    -- Find existing active cart
    IF p_user_id IS NOT NULL THEN
        SELECT cart_id INTO v_cart_id FROM carts WHERE user_id = p_user_id AND status = 'active' LIMIT 1;
    ELSE
        SELECT cart_id INTO v_cart_id FROM carts WHERE session_id = p_session_id AND status = 'active' LIMIT 1;
    END IF;

    -- If no cart exists, create one
    IF v_cart_id IS NULL THEN
        INSERT INTO carts (user_id, session_id, status) VALUES (p_user_id, p_session_id, 'active');
        SET v_cart_id = LAST_INSERT_ID();
    END IF;

    -- Upsert with variant_id
    INSERT INTO cart_items (cart_id, product_id, quantity, price, variant_id)
    VALUES (v_cart_id, p_product_id, p_quantity, p_price, p_variant_id)
    ON DUPLICATE KEY UPDATE quantity = quantity + p_quantity;
    
    SELECT v_cart_id as cart_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CartRemoveItem` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CartRemoveItem`(
    IN p_cart_item_id INT,
    IN p_user_id INT,
    IN p_session_id VARCHAR(255)
)
BEGIN
    DELETE ci FROM cart_items ci
    JOIN carts c ON ci.cart_id = c.cart_id
    WHERE ci.cart_item_id = p_cart_item_id
    AND (
        (c.user_id = p_user_id AND p_user_id IS NOT NULL)
        OR 
        (c.session_id = p_session_id AND p_session_id IS NOT NULL)
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CartSetItemQuantity` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CartSetItemQuantity`(
    IN p_user_id BIGINT,
    IN p_session_id VARCHAR(255),
    IN p_product_id INT,
    IN p_variant_id INT,
    IN p_quantity INT,
    IN p_price DECIMAL(10,2)
)
BEGIN
    DECLARE v_cart_id INT;

    -- Find active cart
    SELECT cart_id INTO v_cart_id
    FROM carts
    WHERE status = 'active'
      AND ((p_user_id IS NOT NULL AND user_id = p_user_id) OR (p_user_id IS NULL AND session_id = p_session_id))
    LIMIT 1;

    -- Create if not exists
    IF v_cart_id IS NULL AND p_quantity > 0 THEN
        INSERT INTO carts (user_id, session_id, status) VALUES (p_user_id, p_session_id, 'active');
        SET v_cart_id = LAST_INSERT_ID();
    END IF;

    IF p_quantity <= 0 THEN
        DELETE FROM cart_items WHERE cart_id = v_cart_id AND product_id = p_product_id AND (variant_id = p_variant_id OR (variant_id IS NULL AND p_variant_id IS NULL));
    ELSE
        IF EXISTS (SELECT 1 FROM cart_items WHERE cart_id = v_cart_id AND product_id = p_product_id AND (variant_id = p_variant_id OR (variant_id IS NULL AND p_variant_id IS NULL))) THEN
            UPDATE cart_items SET quantity = p_quantity, price = p_price
            WHERE cart_id = v_cart_id AND product_id = p_product_id AND (variant_id = p_variant_id OR (variant_id IS NULL AND p_variant_id IS NULL));
        ELSE
            INSERT INTO cart_items (cart_id, product_id, variant_id, quantity, price)
            VALUES (v_cart_id, p_product_id, p_variant_id, p_quantity, p_price);
        END IF;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CartSetProductQuantity` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CartSetProductQuantity`(
    IN p_user_id INT,
    IN p_session_id VARCHAR(255),
    IN p_sku_id BIGINT,
    IN p_quantity INT,
    IN p_price DECIMAL(10,2),
    IN p_variant_id BIGINT
)
BEGIN
    DECLARE v_cart_id BIGINT;
    DECLARE v_stock INT DEFAULT 0;
    DECLARE v_reserved_qty INT DEFAULT 0;
    DECLARE v_current_qty INT DEFAULT 0;

    -- 1. Get Stock Availability (FIXED: Uses SUM to aggregate globally across all stores)
    SELECT COALESCE(SUM(quantity), 0) INTO v_stock 
    FROM sku_inventory 
    WHERE sku_id = p_sku_id 
      AND variant_id <=> p_variant_id;

    -- 2. Get or Create Cart Header (FIXED: Removed store_id dependency)
    SELECT cart_id INTO v_cart_id
    FROM carts
    WHERE status = 'active'
    AND (
        (user_id = p_user_id AND p_user_id IS NOT NULL)
        OR 
        (session_id = p_session_id AND p_session_id IS NOT NULL)
    ) 
    LIMIT 1;

    IF v_cart_id IS NULL THEN
        -- Insert without store_id
        INSERT INTO carts (user_id, session_id, status) 
        VALUES (p_user_id, p_session_id, 'active');
        SET v_cart_id = LAST_INSERT_ID();
    END IF;

    -- 3. Logic Branch
    IF p_quantity <= 0 THEN
        -- Remove Item 
        DELETE FROM cart_items 
        WHERE cart_id = v_cart_id AND product_id = p_sku_id AND variant_id <=> p_variant_id;
    ELSE
        -- Check CURRENT Quantity in cart 
        SELECT quantity INTO v_current_qty
        FROM cart_items 
        WHERE cart_id = v_cart_id AND product_id = p_sku_id AND variant_id <=> p_variant_id
        LIMIT 1;
        
        SET v_current_qty = COALESCE(v_current_qty, 0);

        IF p_quantity > v_current_qty THEN
            -- Calculate Reserved by OTHERS (FIXED: Checked globally, removed c.store_id)
            SELECT COALESCE(SUM(ci.quantity), 0) INTO v_reserved_qty
            FROM cart_items ci
            JOIN carts c ON ci.cart_id = c.cart_id
            WHERE ci.product_id = p_sku_id
            AND ci.variant_id <=> p_variant_id
            AND c.status = 'active'
            AND ci.cart_id != v_cart_id
            AND NOT (
                (p_user_id IS NOT NULL AND c.user_id = p_user_id) 
                OR 
                (p_user_id IS NULL AND c.session_id = p_session_id)
            );

            -- Check Locking against Global Inventory
            IF (v_reserved_qty + p_quantity) > v_stock THEN
                SIGNAL SQLSTATE '45000' 
                SET MESSAGE_TEXT = 'Insufficient stock for this item across the network.';
            END IF;
        END IF;

        -- Proceed with Insert/Update
        IF v_current_qty > 0 THEN
            UPDATE cart_items 
            SET quantity = p_quantity, price = p_price, updated_at = CURRENT_TIMESTAMP
            WHERE cart_id = v_cart_id AND product_id = p_sku_id AND variant_id <=> p_variant_id;
        ELSE
            INSERT INTO cart_items (cart_id, product_id, quantity, price, variant_id)
            VALUES (v_cart_id, p_sku_id, p_quantity, p_price, p_variant_id);
        END IF;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CartUpdateItem` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CartUpdateItem`(
    IN p_cart_item_id INT,
    IN p_quantity INT,
    IN p_user_id INT,
    IN p_session_id VARCHAR(255)
)
BEGIN
    DECLARE v_sku_id INT;
    DECLARE v_variant_id BIGINT;
    DECLARE v_store_id INT;
    DECLARE v_stock INT;
    DECLARE v_reserved_qty INT;
    DECLARE v_current_qty INT;

    -- 1. Identify SKU, Variant, Store, & CURRENT quantity
    SELECT ci.product_id, ci.variant_id, c.store_id, ci.quantity 
    INTO v_sku_id, v_variant_id, v_store_id, v_current_qty
    FROM cart_items ci
    JOIN carts c ON ci.cart_id = c.cart_id
    WHERE ci.cart_item_id = p_cart_item_id;

    -- 2. Only check stock if increasing
    IF p_quantity > v_current_qty THEN
        
        -- FIXED: Filter by variant_id
        SELECT quantity INTO v_stock 
        FROM sku_inventory 
        WHERE sku_id = v_sku_id AND store_id = v_store_id AND variant_id <=> v_variant_id 
        LIMIT 1;

        -- Calculate Reserved by OTHERS (FIXED: Filter by variant_id)
        SELECT COALESCE(SUM(ci.quantity), 0) INTO v_reserved_qty
        FROM cart_items ci
        JOIN carts c ON ci.cart_id = c.cart_id
        WHERE ci.product_id = v_sku_id 
        AND ci.variant_id <=> v_variant_id
        AND c.status = 'active' 
        AND c.store_id = v_store_id
        AND ci.cart_item_id != p_cart_item_id
        AND NOT (
            (p_user_id IS NOT NULL AND c.user_id = p_user_id) 
            OR 
            (p_user_id IS NULL AND c.session_id = p_session_id)
        );

        -- Locking Check
        IF (v_reserved_qty + p_quantity) > v_stock THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Stock unavailable. High demand - item held in other carts.';
        END IF;
    END IF;

    -- 3. Proceed with Update
    UPDATE cart_items ci
    JOIN carts c ON ci.cart_id = c.cart_id
    SET ci.quantity = p_quantity,
        ci.updated_at = CURRENT_TIMESTAMP
    WHERE ci.cart_item_id = p_cart_item_id
    AND (
        (c.user_id = p_user_id AND p_user_id IS NOT NULL)
        OR 
        (c.session_id = p_session_id AND p_session_id IS NOT NULL)
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CheckMediaExists` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckMediaExists`(IN p_sku_id BIGINT, IN p_variant_id BIGINT, IN p_media_url VARCHAR(255))
BEGIN
    SELECT media_id FROM sku_media 
    WHERE sku_id = p_sku_id 
      AND media_url = p_media_url 
      AND variant_id <=> p_variant_id 
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ClearProductVariants` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `ClearProductVariants`(IN p_sku_id BIGINT)
BEGIN
    -- Safe cleanup: remove from active carts and local inventory to prevent orphans/crashes
    DELETE FROM cart_items WHERE variant_id IN (SELECT variant_id FROM sku_variant WHERE sku_id = p_sku_id);
    DELETE FROM sku_inventory WHERE variant_id IN (SELECT variant_id FROM sku_variant WHERE sku_id = p_sku_id);
    DELETE FROM sku_variant WHERE sku_id = p_sku_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CloneOrderToCart` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CloneOrderToCart`(
    IN p_order_id BIGINT,
    IN p_user_id INT,
    IN p_session_id VARCHAR(255)
)
BEGIN
    DECLARE v_cart_id BIGINT;
    
    -- Cursor variables
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_prod_id BIGINT;
    DECLARE v_var_id BIGINT;
    DECLARE v_qty INT;
    DECLARE v_price DECIMAL(10,2);
    
    DECLARE v_avail_stock INT;
    DECLARE v_current_cart_qty INT;
    DECLARE v_final_qty INT;

    -- Cursor to loop through the old order items (ignoring discontinued products)
    DECLARE order_cursor CURSOR FOR 
        SELECT oi.product_id, oi.variant_id, oi.quantity, oi.price 
        FROM order_items oi
        JOIN sku_master sm ON oi.product_id = sm.sku_id
        WHERE oi.order_id = p_order_id AND sm.is_active = 1;

    -- The kill-switch for the cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- 1. Cart Management (Global Cart - Store ID removed entirely)
    SELECT cart_id INTO v_cart_id FROM carts
    WHERE status = 'active'
      AND ((user_id = p_user_id AND p_user_id IS NOT NULL) OR (session_id = p_session_id AND p_session_id IS NOT NULL)) 
    LIMIT 1;

    IF v_cart_id IS NULL THEN
        -- Insert into carts without store_id
        INSERT INTO carts (user_id, session_id, status) VALUES (p_user_id, p_session_id, 'active');
        SET v_cart_id = LAST_INSERT_ID();
    END IF;

    -- 2. Loop through old order items and add them to the global cart safely!
    OPEN order_cursor;
    
    read_loop: LOOP
        FETCH order_cursor INTO v_prod_id, v_var_id, v_qty, v_price;
        
        IF done THEN LEAVE read_loop; END IF;

        -- Calculate ACTUAL available stock globally across all network nodes
        SET v_avail_stock = COALESCE((
            SELECT GREATEST(0, SUM(quantity) - COALESCE(MAX(low_stock_threshold), 0))
            FROM sku_inventory
            WHERE sku_id = v_prod_id AND variant_id <=> v_var_id 
        ), 0);

        -- See if it's already in their current global cart
        SET v_current_cart_qty = COALESCE((
            SELECT quantity
            FROM cart_items 
            WHERE cart_id = v_cart_id AND product_id = v_prod_id AND variant_id <=> v_var_id 
            LIMIT 1
        ), 0);

        -- Add old qty to current cart qty, but NEVER exceed available global stock!
        SET v_final_qty = v_current_cart_qty + v_qty;
        
        IF v_final_qty > v_avail_stock THEN
            SET v_final_qty = v_avail_stock;
        END IF;

        -- Upsert into cart
        IF v_final_qty > 0 THEN
            IF v_current_cart_qty > 0 THEN
                UPDATE cart_items 
                SET quantity = v_final_qty, updated_at = CURRENT_TIMESTAMP 
                WHERE cart_id = v_cart_id AND product_id = v_prod_id AND variant_id <=> v_var_id;
            ELSE
                -- Note: Grabs the CURRENT price from sku_variant/sku_master, not the historical order price!
                SET v_price = COALESCE(
                    (SELECT price FROM sku_variant WHERE variant_id = v_var_id LIMIT 1), 
                    (SELECT price FROM sku_master WHERE sku_id = v_prod_id LIMIT 1)
                );
                
                INSERT INTO cart_items (cart_id, product_id, variant_id, quantity, price) 
                VALUES (v_cart_id, v_prod_id, v_var_id, v_final_qty, v_price);
            END IF;
        END IF;

    END LOOP;
    
    CLOSE order_cursor;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CreateArea` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateArea`(IN p_region_id INT, IN p_name VARCHAR(255))
BEGIN
    INSERT INTO areas (region_id, name) VALUES (p_region_id, p_name);
    SELECT LAST_INSERT_ID() as new_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CreateB2BProduct` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateB2BProduct`(
    IN p_name VARCHAR(255), IN p_description TEXT, IN p_product_definition TEXT,
    IN p_sku VARCHAR(100), IN p_category_id INT, IN p_brand_id INT,
    IN p_specifications TEXT, IN p_warranty_info TEXT, IN p_manufacturer_info TEXT,
    IN p_price DECIMAL(10,2), IN p_inventory_json JSON, IN p_volume_json JSON,
    IN p_gtin VARCHAR(100), IN p_mpn VARCHAR(100), IN p_old_price DECIMAL(10,2),
    IN p_cost DECIMAL(10,2), IN p_disable_buy BOOLEAN, IN p_call_price BOOLEAN,
    IN p_weight DECIMAL(10,2), IN p_length DECIMAL(10,2), IN p_width DECIMAL(10,2),
    IN p_height DECIMAL(10,2), IN p_min_qty INT, IN p_max_qty INT,
    IN p_not_returnable BOOLEAN, IN p_admin_comment TEXT,
    IN p_is_active BOOLEAN,
    IN p_case_pack INT -- NEW PARAMETER
)
BEGIN
    DECLARE v_sku_id BIGINT;
    DECLARE i INT DEFAULT 0;
    DECLARE v_count INT;
    DECLARE v_curr_store INT;
    
    INSERT INTO sku_master (
        name, description, product_definition, sku, category_id, brand_id, 
        specifications, warranty_info, manufacturer_info, price, is_active,
        gtin, manufacturer_part_number, old_price, product_cost, disable_buy_button, call_for_price,
        weight, length, width, height, minimum_cart_qty, maximum_cart_qty, case_pack_quantity, not_returnable, admin_comment
    ) VALUES (
        p_name, p_description, p_product_definition, p_sku, p_category_id, p_brand_id, 
        p_specifications, p_warranty_info, p_manufacturer_info, p_price, p_is_active,
        p_gtin, p_mpn, p_old_price, p_cost, p_disable_buy, p_call_price,
        p_weight, p_length, p_width, p_height, p_min_qty, p_max_qty, p_case_pack, p_not_returnable, p_admin_comment
    );
    
    SET v_sku_id = LAST_INSERT_ID();
    
    IF p_inventory_json IS NOT NULL THEN
        SET v_count = JSON_LENGTH(p_inventory_json);
        WHILE i < v_count DO
            SET v_curr_store = JSON_UNQUOTE(JSON_EXTRACT(p_inventory_json, CONCAT('$[', i, '].store_id')));
            INSERT INTO sku_inventory (sku_id, store_id, quantity, low_stock_threshold)
            VALUES (
                v_sku_id, v_curr_store,
                JSON_UNQUOTE(JSON_EXTRACT(p_inventory_json, CONCAT('$[', i, '].quantity'))),
                JSON_UNQUOTE(JSON_EXTRACT(p_inventory_json, CONCAT('$[', i, '].threshold')))
            );
            SET i = i + 1;
        END WHILE;
    END IF;
    
    IF p_volume_json IS NOT NULL THEN
        SET v_count = JSON_LENGTH(p_volume_json);
        SET i = 0;
        WHILE i < v_count DO
            INSERT INTO sku_volume_pricing (sku_id, min_quantity, price)
            VALUES (
                v_sku_id,
                JSON_UNQUOTE(JSON_EXTRACT(p_volume_json, CONCAT('$[', i, '].min_quantity'))),
                JSON_UNQUOTE(JSON_EXTRACT(p_volume_json, CONCAT('$[', i, '].price')))
            );
            SET i = i + 1;
        END WHILE;
    END IF;
    
    SELECT v_sku_id AS new_product_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CreateBrand` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateBrand`(IN p_name VARCHAR(255), IN p_description TEXT)
BEGIN
    INSERT INTO brands (name, description) VALUES (p_name, p_description);
    SELECT LAST_INSERT_ID() AS new_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CreateCategory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateCategory`(IN p_name VARCHAR(255), IN p_description TEXT, IN p_image_url VARCHAR(255))
BEGIN
    INSERT INTO categories (name, description, image_url) VALUES (p_name, p_description, p_image_url);
    SELECT LAST_INSERT_ID() AS new_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CreateOrderFromCart` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateOrderFromCart`(
    IN p_user_id BIGINT,
    IN p_session_id VARCHAR(255),
    IN p_shipping_addr TEXT,
    IN p_billing_addr TEXT,
    IN p_total DECIMAL(10,2)
)
BEGIN
    DECLARE v_order_id BIGINT;
    DECLARE v_order_num VARCHAR(50);
    DECLARE v_cart_id BIGINT;

    -- 1. Find the active cart globally (Removed store_id)
    SELECT cart_id INTO v_cart_id FROM carts 
    WHERE status = 'active' 
      AND (user_id = p_user_id OR (user_id IS NULL AND session_id = p_session_id)) 
    LIMIT 1;

    IF v_cart_id IS NOT NULL THEN

        -- Removed PRE-CHECK: Global Inventory Validation
        
        SET v_order_num = CONCAT('ORD-', UNIX_TIMESTAMP());

        -- 2. Create the Order globally (Removed store_id)
        INSERT INTO orders (order_number, user_id, total_amount, shipping_address, billing_address, order_status)
        VALUES (v_order_num, p_user_id, p_total, p_shipping_addr, p_billing_addr, 'pending');
        
        SET v_order_id = LAST_INSERT_ID();

        -- 3. Move items from Cart to Order
        INSERT INTO order_items (order_id, product_id, variant_id, product_name, quantity, price)
        SELECT v_order_id, ci.product_id, ci.variant_id, sm.name, ci.quantity, ci.price 
        FROM cart_items ci
        JOIN sku_master sm ON ci.product_id = sm.sku_id
        WHERE ci.cart_id = v_cart_id;

        -- NOTE: Physical inventory deduction (UPDATE sku_inventory) is omitted here.
        -- In a global network, exact stock is deducted during warehouse allocation/picking.

        -- 4. Close the Cart
        UPDATE carts SET status = 'converted' WHERE cart_id = v_cart_id;
        
        SELECT v_order_id as order_id, v_order_num as order_number;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No active cart found';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CreateProductVariant` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateProductVariant`(
    IN p_sku_id BIGINT,
    IN p_sku VARCHAR(100),
    IN p_price DECIMAL(10,2),
    IN p_combination_key VARCHAR(255)
)
BEGIN
    INSERT INTO sku_variant (sku_id, sku, price, combination_key) 
    VALUES (p_sku_id, p_sku, p_price, p_combination_key);
    
    SELECT LAST_INSERT_ID() AS new_variant_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CreateRegion` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateRegion`(IN p_name VARCHAR(255))
BEGIN
    INSERT INTO regions (name) VALUES (p_name);
    SELECT LAST_INSERT_ID() as new_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CreateRestaurantFacility` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateRestaurantFacility`(
    IN p_name VARCHAR(255), 
    IN p_code VARCHAR(100), 
    IN p_address VARCHAR(255), 
    IN p_city VARCHAR(100), 
    IN p_state VARCHAR(50), 
    IN p_zip VARCHAR(20),
    IN p_tax_rate DECIMAL(5,2)
)
BEGIN
    INSERT INTO restaurants (restaurant_name, restaurant_code, address, city, state, zip, tax_rate, is_active)
    VALUES (p_name, p_code, p_address, p_city, p_state, p_zip, p_tax_rate, 1);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CreateStore` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateStore`(
    IN p_area_id INT, IN p_name VARCHAR(255), IN p_code VARCHAR(50),
    IN p_min_order DECIMAL(10,2), IN p_max_order DECIMAL(10,2), IN p_approval DECIMAL(10,2)
)
BEGIN
    INSERT INTO stores (
        area_id, name, store_code, 
        min_order_value, max_order_value, approval_threshold
    ) VALUES (
        p_area_id, p_name, p_code, 
        p_min_order, p_max_order, p_approval
    );
    SELECT LAST_INSERT_ID() as new_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CreateUser` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateUser`(
    IN p_username VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_password_hash VARCHAR(255)
)
BEGIN
    INSERT INTO users (username, email, password_hash)
    VALUES (p_username, p_email, p_password_hash);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `DeleteAddress` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteAddress`(
    IN p_address_id INT,
    IN p_user_id INT
)
BEGIN
SET SQL_SAFE_UPDATES = 0;
    DELETE FROM user_addresses
    WHERE address_id = p_address_id AND user_id = p_user_id;
SET SQL_SAFE_UPDATES = 1; 
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `DeleteProductMedia` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteProductMedia`(IN p_media_id BIGINT)
BEGIN
    DELETE FROM sku_media WHERE media_id = p_media_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `DeleteSingleVariant` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteSingleVariant`(IN p_sku_id BIGINT, IN p_variant_id BIGINT)
BEGIN
    DELETE FROM cart_items WHERE variant_id = p_variant_id;
    DELETE FROM sku_inventory WHERE variant_id = p_variant_id;
    DELETE FROM sku_variant WHERE variant_id = p_variant_id AND sku_id = p_sku_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAdminCatalogDependencies` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAdminCatalogDependencies`()
BEGIN
    SELECT category_id, name FROM categories ORDER BY name;
    SELECT brand_id, name FROM brands ORDER BY name;
    SELECT store_id, name, store_code FROM stores WHERE is_active = 1 ORDER BY name;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAdminProductEditData` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAdminProductEditData`(IN p_sku_id BIGINT)
BEGIN
    -- 1. Master Product Data
    SELECT * FROM sku_master WHERE sku_id = p_sku_id;
    
    -- 2. Variants Data
    SELECT * FROM sku_variant WHERE sku_id = p_sku_id;
    
    -- 3. Variant Attributes Mapping
    SELECT sva.variant_id, sa.attribute_name, sav.attribute_value 
    FROM sku_variant_attributes sva
    JOIN sku_attribute_values sav ON sva.value_id = sav.value_id
    JOIN sku_attributes sa ON sav.attribute_id = sa.attribute_id
    WHERE sva.variant_id IN (SELECT variant_id FROM sku_variant WHERE sku_id = p_sku_id);
    
    -- 4. Multi-Tenant Inventory Data
    SELECT si.*, s.name as store_name, s.store_code as store_code 
    FROM sku_inventory si
    JOIN stores s ON si.store_id = s.store_id
    WHERE si.sku_id = p_sku_id;
    
    -- 5. Media Data
    SELECT * FROM sku_media WHERE sku_id = p_sku_id ORDER BY display_order ASC;
    
    -- 6. Volume Pricing
    SELECT * FROM sku_volume_pricing WHERE sku_id = p_sku_id ORDER BY min_quantity ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAdminProductForEdit` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAdminProductForEdit`(IN p_sku_id BIGINT)
BEGIN
    -- Product Header (Detects if it currently uses variants based on existence in sku_variant)
    SELECT 
        sm.sku_id, sm.name, sm.sku, sm.price, sm.description, 
        sm.category_id, sm.brand_id, sm.gtin, sm.manufacturer_part_number, 
        sm.is_active,
        IF(EXISTS(SELECT 1 FROM sku_variant WHERE sku_id = sm.sku_id), 1, 0) AS has_variants
    FROM sku_master sm 
    WHERE sm.sku_id = p_sku_id;

    -- Variants List (If any)
    SELECT sv.variant_id AS id, sv.sku, sv.price, sv.combination_key AS name
    FROM sku_variant sv 
    WHERE sv.sku_id = p_sku_id
    ORDER BY sv.variant_id ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAdminProducts` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAdminProducts`()
BEGIN
    SELECT 
        sm.sku_id, 
        sm.name, 
        sm.sku, 
        sm.price, 
        sm.is_active,
        c.name AS category_name, 
        b.name AS brand_name,
        
        -- FIX 1: Sum across ALL variants (Removed `variant_id IS NULL`)
        COALESCE((SELECT SUM(quantity) FROM sku_inventory WHERE sku_id = sm.sku_id), 0) AS total_stock,
        
        -- FIX 2: Aggregate specific variant stock into a JSON array for the frontend
        COALESCE((
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'variant_name', COALESCE(sv.combination_key, 'Base Product'),
                    'sku', COALESCE(sv.sku, sm.sku),
                    'quantity', COALESCE(inv.qty, 0)
                )
            )
            FROM (
                SELECT variant_id, SUM(quantity) AS qty 
                FROM sku_inventory 
                WHERE sku_id = sm.sku_id 
                GROUP BY variant_id
            ) inv
            LEFT JOIN sku_variant sv ON inv.variant_id = sv.variant_id
        ), '[]') AS variant_details
        
    FROM sku_master sm
    LEFT JOIN categories c ON sm.category_id = c.category_id
    LEFT JOIN brands b ON sm.brand_id = b.brand_id
    ORDER BY sm.created_at DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAdminRestaurants` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAdminRestaurants`()
BEGIN
    SELECT 
        restaurant_id, 
        restaurant_name, 
        restaurant_code, 
        address, 
        city, 
        state, 
        zip, 
        COALESCE(tax_rate, 0.00) AS tax_rate, 
        is_active 
    FROM restaurants 
    ORDER BY restaurant_name ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAdminWarehouses` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAdminWarehouses`()
BEGIN
    SELECT store_id, name, store_code 
    FROM stores 
    WHERE is_active = 1 
    ORDER BY name ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAllBrands` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllBrands`()
BEGIN
    SELECT * FROM brands ORDER BY name;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAllCategories` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllCategories`()
BEGIN
    SELECT * FROM categories ORDER BY name;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAllGlobalOrders` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllGlobalOrders`()
BEGIN
    SELECT 
        o.order_id, o.order_number, o.created_at, o.total_amount, o.order_status,
        u.first_name, u.last_name, o.guest_email, o.shipping_address,
        (SELECT SUM(quantity) FROM order_items WHERE order_id = o.order_id) AS total_items,
        (SELECT COALESCE(SUM(allocated_qty), 0) FROM order_allocations WHERE order_id = o.order_id) AS allocated_items,
        
        -- NEW DOM FEATURE: Fetch the exact breakdown of which warehouse is doing what!
        COALESCE((
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'store_name', s.name,
                    'store_code', s.store_code,
                    'allocated_qty', oa.qty,
                    'status', oa.status
                )
            )
            FROM (
                -- We group by store and status so the Admin sees cleanly: "Warehouse A: 10 Shipped, 2 Picking"
                SELECT store_id, status, SUM(allocated_qty) as qty
                FROM order_allocations
                WHERE order_id = o.order_id
                GROUP BY store_id, status
            ) oa
            JOIN stores s ON oa.store_id = s.store_id
        ), '[]') AS node_statuses
        
    FROM orders o
    LEFT JOIN users u ON o.user_id = u.user_id
    ORDER BY o.created_at DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAllProducts` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllProducts`(IN p_user_id BIGINT, IN p_guest_id VARCHAR(255))
BEGIN
    SELECT 
        sm.sku_id AS product_id, sm.name, sm.description, sm.sku,
        (SELECT GROUP_CONCAT(sku SEPARATOR ', ') FROM sku_variant WHERE sku_id = sm.sku_id) AS variant_skus,
        COALESCE((SELECT MIN(price) FROM sku_variant WHERE sku_id = sm.sku_id), sm.price, 0) AS price,
        COALESCE((SELECT media_url FROM sku_media WHERE sku_id = sm.sku_id AND media_type = 'image' ORDER BY is_primary DESC, display_order ASC LIMIT 1), sm.image_url) AS image_url,
        c.name AS category_name, b.name AS brand_name,
        IF(EXISTS(SELECT 1 FROM sku_variant WHERE sku_id = sm.sku_id), 1, 0) AS has_variants,
        
        -- AGGREGATE STOCK GLOBALLY
        COALESCE((SELECT SUM(quantity) FROM sku_inventory WHERE sku_id = sm.sku_id), 0) AS stock_quantity,
        
        COALESCE(
            (SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id', sv.variant_id, 'name', sv.combination_key, 'sku', sv.sku, 'price', sv.price,
                    'image', COALESCE((SELECT media_url FROM sku_media WHERE sku_id = sm.sku_id AND variant_id = sv.variant_id AND media_type = 'image' ORDER BY is_primary DESC, display_order ASC LIMIT 1), sv.image_url),
                    'stock', COALESCE((SELECT SUM(quantity) FROM sku_inventory si WHERE si.variant_id = sv.variant_id), 0),
                    'cart_quantity', COALESCE((SELECT SUM(ci.quantity) FROM cart_items ci JOIN carts cart ON ci.cart_id = cart.cart_id WHERE ci.variant_id = sv.variant_id AND cart.status = 'active' AND ((p_user_id IS NOT NULL AND cart.user_id = p_user_id) OR (p_user_id IS NULL AND cart.session_id = p_guest_id))), 0)
                )
             ) FROM sku_variant sv WHERE sv.sku_id = sm.sku_id), '[]'
        ) AS variants_json,
        COALESCE((SELECT SUM(ci.quantity) FROM cart_items ci JOIN carts cart ON ci.cart_id = cart.cart_id WHERE ci.product_id = sm.sku_id AND ci.variant_id IS NULL AND cart.status = 'active' AND ((p_user_id IS NOT NULL AND cart.user_id = p_user_id) OR (p_user_id IS NULL AND cart.session_id = p_guest_id))), 0) AS base_cart_quantity,
        
        -- NEW: Check if it's favorited by the user
        IF(p_user_id IS NOT NULL AND EXISTS(SELECT 1 FROM user_favorite_products WHERE user_id = p_user_id AND product_id = sm.sku_id), 1, 0) AS is_favorite
        
    FROM sku_master sm
    LEFT JOIN categories c ON sm.category_id = c.category_id
    LEFT JOIN brands b ON sm.brand_id = b.brand_id
    WHERE sm.is_active = 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetBrandsList` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetBrandsList`()
BEGIN
    SELECT b.*, (SELECT COUNT(*) FROM sku_master sm WHERE sm.brand_id = b.brand_id) as product_count 
    FROM brands b 
    ORDER BY b.name;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetCartCount` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCartCount`(
    IN p_user_id INT,
    IN p_session_id VARCHAR(255)
)
BEGIN
    SELECT COALESCE(SUM(ci.quantity), 0) as total_items
    FROM cart_items ci
    JOIN carts c ON ci.cart_id = c.cart_id
    WHERE c.status = 'active'
    AND (
        (c.user_id = p_user_id AND p_user_id IS NOT NULL)
        OR 
        (c.session_id = p_session_id AND p_session_id IS NOT NULL)
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetCartDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCartDetails`(IN p_user_id BIGINT, IN p_session_id VARCHAR(255))
BEGIN
    SELECT ci.cart_item_id, ci.cart_id, ci.product_id, ci.variant_id, ci.quantity, ci.price,
           sm.name AS product_name,
           COALESCE(sv.sku, sm.sku) AS sku,
           
           -- THE FIX: Attempt to fetch the EXACT variant image first. 
           -- If it doesn't exist, fall back to the base product image.
           COALESCE(
               (SELECT media_url FROM sku_media WHERE sku_id = sm.sku_id AND variant_id = sv.variant_id AND media_type = 'image' ORDER BY is_primary DESC LIMIT 1),
               (SELECT media_url FROM sku_media WHERE sku_id = sm.sku_id AND variant_id IS NULL AND media_type = 'image' ORDER BY is_primary DESC LIMIT 1),
               sm.image_url
           ) AS image_url,
           
           COALESCE(sv.combination_key, '') AS variant_name
           
    FROM cart_items ci
    JOIN carts c ON ci.cart_id = c.cart_id
    JOIN sku_master sm ON ci.product_id = sm.sku_id
    LEFT JOIN sku_variant sv ON ci.variant_id = sv.variant_id
    WHERE c.status = 'active'
      AND ((p_user_id IS NOT NULL AND c.user_id = p_user_id) OR (p_user_id IS NULL AND c.session_id = p_session_id));
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetCartItemCount` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCartItemCount`(IN p_user_id BIGINT, IN p_session_id VARCHAR(255))
BEGIN
    SELECT COALESCE(SUM(ci.quantity), 0) AS total_items
    FROM cart_items ci
    JOIN carts c ON ci.cart_id = c.cart_id
    WHERE c.status = 'active'
      AND ((p_user_id IS NOT NULL AND c.user_id = p_user_id) OR (p_user_id IS NULL AND c.session_id = p_session_id));
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetCategoriesList` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCategoriesList`()
BEGIN
    SELECT category_id, name, description, image_url, created_at 
    FROM categories 
    ORDER BY name ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetCategoryName` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCategoryName`(IN p_category_id INT)
BEGIN
    SELECT name FROM categories WHERE category_id = p_category_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetCustomerTrackOrderItems` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCustomerTrackOrderItems`(IN p_order_id BIGINT)
BEGIN
    SELECT 
        oi.order_item_id, 
        oi.product_name, 
        oi.quantity, 
        oi.price,
        COALESCE(sv.combination_key, '') AS variant_name,
        COALESCE(
            (SELECT media_url FROM sku_media WHERE sku_id = sm.sku_id AND (variant_id = oi.variant_id OR variant_id IS NULL) AND media_type = 'image' ORDER BY is_primary DESC LIMIT 1), 
            sm.image_url
        ) AS image_url,
        
        -- NEW: Aggregate the exact allocations into a JSON array 
        COALESCE((
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'status', allocs.status,
                    'qty', allocs.total_qty
                )
            )
            FROM (
                SELECT status, SUM(allocated_qty) as total_qty
                FROM order_allocations
                WHERE order_item_id = oi.order_item_id
                GROUP BY status
            ) allocs
        ), '[]') AS allocations_json
        
    FROM order_items oi
    JOIN sku_master sm ON oi.product_id = sm.sku_id
    LEFT JOIN sku_variant sv ON oi.variant_id = sv.variant_id
    WHERE oi.order_id = p_order_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetFavoriteProducts` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetFavoriteProducts`(IN p_user_id BIGINT, IN p_guest_id VARCHAR(255))
BEGIN
    SELECT 
        sm.sku_id AS product_id, sm.name, sm.description, sm.sku,
        (SELECT GROUP_CONCAT(sku SEPARATOR ', ') FROM sku_variant WHERE sku_id = sm.sku_id) AS variant_skus,
        COALESCE((SELECT MIN(price) FROM sku_variant WHERE sku_id = sm.sku_id), sm.price, 0) AS price,
        COALESCE((SELECT media_url FROM sku_media WHERE sku_id = sm.sku_id AND media_type = 'image' ORDER BY is_primary DESC, display_order ASC LIMIT 1), sm.image_url) AS image_url,
        c.name AS category_name, b.name AS brand_name,
        IF(EXISTS(SELECT 1 FROM sku_variant WHERE sku_id = sm.sku_id), 1, 0) AS has_variants,
        COALESCE((SELECT SUM(quantity) FROM sku_inventory WHERE sku_id = sm.sku_id), 0) AS stock_quantity,
        COALESCE(
            (SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id', sv.variant_id, 'name', sv.combination_key, 'sku', sv.sku, 'price', sv.price,
                    'image', COALESCE((SELECT media_url FROM sku_media WHERE sku_id = sm.sku_id AND variant_id = sv.variant_id AND media_type = 'image' ORDER BY is_primary DESC, display_order ASC LIMIT 1), sv.image_url),
                    'stock', COALESCE((SELECT SUM(quantity) FROM sku_inventory si WHERE si.variant_id = sv.variant_id), 0),
                    'cart_quantity', COALESCE((SELECT SUM(ci.quantity) FROM cart_items ci JOIN carts cart ON ci.cart_id = cart.cart_id WHERE ci.variant_id = sv.variant_id AND cart.status = 'active' AND ((p_user_id IS NOT NULL AND cart.user_id = p_user_id) OR (p_user_id IS NULL AND cart.session_id = p_guest_id))), 0)
                )
             ) FROM sku_variant sv WHERE sv.sku_id = sm.sku_id), '[]'
        ) AS variants_json,
        COALESCE((SELECT SUM(ci.quantity) FROM cart_items ci JOIN carts cart ON ci.cart_id = cart.cart_id WHERE ci.product_id = sm.sku_id AND ci.variant_id IS NULL AND cart.status = 'active' AND ((p_user_id IS NOT NULL AND cart.user_id = p_user_id) OR (p_user_id IS NULL AND cart.session_id = p_guest_id))), 0) AS base_cart_quantity,
        1 AS is_favorite
    FROM sku_master sm
    JOIN user_favorite_products ufp ON sm.sku_id = ufp.product_id AND ufp.user_id = p_user_id
    LEFT JOIN categories c ON sm.category_id = c.category_id
    LEFT JOIN brands b ON sm.brand_id = b.brand_id
    WHERE sm.is_active = 1
    ORDER BY ufp.created_at DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetFrequentlyOrderedProducts` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetFrequentlyOrderedProducts`(IN p_user_id BIGINT, IN p_guest_id VARCHAR(255))
BEGIN
    SELECT 
        sm.sku_id AS product_id, sm.name, sm.description, sm.sku,
        (SELECT GROUP_CONCAT(sku SEPARATOR ', ') FROM sku_variant WHERE sku_id = sm.sku_id) AS variant_skus,
        COALESCE((SELECT MIN(price) FROM sku_variant WHERE sku_id = sm.sku_id), sm.price, 0) AS price,
        COALESCE((SELECT media_url FROM sku_media WHERE sku_id = sm.sku_id AND media_type = 'image' ORDER BY is_primary DESC, display_order ASC LIMIT 1), sm.image_url) AS image_url,
        c.name AS category_name, b.name AS brand_name,
        IF(EXISTS(SELECT 1 FROM sku_variant WHERE sku_id = sm.sku_id), 1, 0) AS has_variants,
        COALESCE((SELECT SUM(quantity) FROM sku_inventory WHERE sku_id = sm.sku_id), 0) AS stock_quantity,
        COALESCE(
            (SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id', sv.variant_id, 'name', sv.combination_key, 'sku', sv.sku, 'price', sv.price,
                    'image', COALESCE((SELECT media_url FROM sku_media WHERE sku_id = sm.sku_id AND variant_id = sv.variant_id AND media_type = 'image' ORDER BY is_primary DESC, display_order ASC LIMIT 1), sv.image_url),
                    'stock', COALESCE((SELECT SUM(quantity) FROM sku_inventory si WHERE si.variant_id = sv.variant_id), 0),
                    'cart_quantity', COALESCE((SELECT SUM(ci.quantity) FROM cart_items ci JOIN carts cart ON ci.cart_id = cart.cart_id WHERE ci.variant_id = sv.variant_id AND cart.status = 'active' AND ((p_user_id IS NOT NULL AND cart.user_id = p_user_id) OR (p_user_id IS NULL AND cart.session_id = p_guest_id))), 0)
                )
             ) FROM sku_variant sv WHERE sv.sku_id = sm.sku_id), '[]'
        ) AS variants_json,
        COALESCE((SELECT SUM(ci.quantity) FROM cart_items ci JOIN carts cart ON ci.cart_id = cart.cart_id WHERE ci.product_id = sm.sku_id AND ci.variant_id IS NULL AND cart.status = 'active' AND ((p_user_id IS NOT NULL AND cart.user_id = p_user_id) OR (p_user_id IS NULL AND cart.session_id = p_guest_id))), 0) AS base_cart_quantity,
        IF(EXISTS(SELECT 1 FROM user_favorite_products WHERE user_id = p_user_id AND product_id = sm.sku_id), 1, 0) AS is_favorite
    FROM sku_master sm
    JOIN (
        SELECT oi.product_id, COUNT(*) as order_count
        FROM order_items oi
        JOIN orders o ON oi.order_id = o.order_id
        WHERE o.user_id = p_user_id
        GROUP BY oi.product_id
        ORDER BY order_count DESC
        LIMIT 10
    ) freq ON sm.sku_id = freq.product_id
    LEFT JOIN categories c ON sm.category_id = c.category_id
    LEFT JOIN brands b ON sm.brand_id = b.brand_id
    WHERE sm.is_active = 1
    ORDER BY freq.order_count DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetGlobalAdminDashboardStats` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetGlobalAdminDashboardStats`()
BEGIN
    SELECT 
        (SELECT COUNT(*) FROM orders WHERE DATE(created_at) = CURDATE()) AS orders_today,
        (SELECT COUNT(*) FROM orders WHERE order_status IN ('pending', 'processing', 'partially_shipped')) AS active_orders,
        (SELECT COUNT(*) FROM inventory_exceptions WHERE status = 'pending') AS pending_exceptions,
        (SELECT COUNT(*) FROM stores WHERE is_active = 1) AS active_stores;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetGlobalOrderDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetGlobalOrderDetails`(IN p_order_id BIGINT)
BEGIN
    -- Result 1: Order Header
    SELECT o.*, s.name AS store_name, u.first_name, u.last_name, u.email, u.phone
    FROM orders o
    JOIN stores s ON o.store_id = s.store_id
    JOIN users u ON o.user_id = u.user_id
    WHERE o.order_id = p_order_id;

    -- Result 2: Items Purchased
    SELECT oi.*, sm.sku, 
        COALESCE((SELECT combination_key FROM sku_variant WHERE variant_id = oi.variant_id), 'Standard') as variant_name
    FROM order_items oi
    JOIN sku_master sm ON oi.product_id = sm.sku_id
    WHERE oi.order_id = p_order_id;

    -- Result 3: Any Warehouse Exceptions (Short Picks)
    SELECT ie.*, sm.name as product_name, sm.sku, u.first_name as reported_by_name
    FROM inventory_exceptions ie
    JOIN sku_master sm ON ie.product_id = sm.sku_id
    JOIN users u ON ie.reported_by = u.user_id
    WHERE ie.order_id = p_order_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetGlobalOrders` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetGlobalOrders`()
BEGIN
    SELECT 
        o.order_id, o.order_number, o.order_status, o.total_amount, o.created_at,
        s.name AS store_name, 
        u.first_name, u.last_name, u.email,
        -- Helpdesk needs to know immediately if a restaurant order has missing items!
        (SELECT COUNT(*) FROM inventory_exceptions ie WHERE ie.order_id = o.order_id) as exception_count
    FROM orders o
    JOIN stores s ON o.store_id = s.store_id
    JOIN users u ON o.user_id = u.user_id
    ORDER BY o.created_at DESC 
    LIMIT 500; -- Limit to recent 500 for performance, searchable via UI
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetGlobalPendingExceptions` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetGlobalPendingExceptions`()
BEGIN
    SELECT 
        e.exception_id, 
        e.order_id, 
        o.order_number,
        s.name AS warehouse_name,
        s.store_code AS warehouse_code,
        u.first_name AS reported_by_first,
        u.last_name AS reported_by_last,
        sm.name AS product_name,
        sv.combination_key AS variant_name,
        
        -- Exact variant SKU if it exists, otherwise base SKU
        COALESCE(sv.sku, sm.sku) AS sku,
        
        -- CALCULATED FIELD: Ordered minus what was actually picked
        (e.expected_qty - e.actual_picked_qty) AS missing_quantity,
        
        e.status,
        e.created_at
    FROM inventory_exceptions e
    JOIN orders o ON e.order_id = o.order_id
    
    -- THE FIX: We must join on e.store_id (where the exception happened), NOT o.store_id!
    JOIN stores s ON e.store_id = s.store_id
    
    LEFT JOIN users u ON e.reported_by = u.user_id
    JOIN sku_master sm ON e.product_id = sm.sku_id
    LEFT JOIN sku_variant sv ON e.variant_id = sv.variant_id
    WHERE e.status = 'pending'
    ORDER BY e.created_at DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetGroupedProductChildren` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetGroupedProductChildren`(IN p_parent_id INT)
BEGIN
    SELECT 
        c.child_id AS product_id, sm.name, sm.sku, sm.price,
        COALESCE((SELECT media_url FROM sku_media WHERE sku_id = sm.sku_id AND media_type = 'image' ORDER BY is_primary DESC, display_order ASC LIMIT 1), sm.image_url) AS image_url,
        
        -- AGGREGATE STOCK GLOBALLY
        COALESCE((SELECT SUM(quantity) FROM sku_inventory WHERE sku_id = sm.sku_id), 0) AS stock_quantity
        
    FROM product_group_children c
    JOIN sku_master sm ON c.child_id = sm.sku_id
    WHERE c.parent_id = p_parent_id AND sm.is_active = 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetOrderByNumber` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetOrderByNumber`(IN p_order_number VARCHAR(50))
BEGIN
    SELECT o.*, u.first_name, u.last_name 
    FROM orders o 
    LEFT JOIN users u ON o.user_id = u.user_id 
    WHERE o.order_number = p_order_number;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetOrderItems` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetOrderItems`(IN p_order_id BIGINT)
BEGIN
    DECLARE v_global_status VARCHAR(50);
    
    -- Check if the entire order was forcefully cancelled
    SELECT order_status INTO v_global_status FROM orders WHERE order_id = p_order_id;

    SELECT 
        oi.*, 
        sm.name AS product_name, 
        
        -- Fetch specific variant image from sku_media
        COALESCE(
            (SELECT media_url FROM sku_media WHERE sku_id = sm.sku_id AND variant_id = oi.variant_id AND media_type = 'image' ORDER BY is_primary DESC, display_order ASC LIMIT 1),
            (SELECT media_url FROM sku_media WHERE sku_id = sm.sku_id AND variant_id IS NULL AND media_type = 'image' ORDER BY is_primary DESC, display_order ASC LIMIT 1),
            sm.image_url
        ) AS image_url,
        
        COALESCE(sv.combination_key, '') AS variant_name,
        c.name as category,
        
        -- ==============================================================
        -- EXACT MATHEMATICAL DOM LIFECYCLE (JSON Array)
        -- Uses CAST to SIGNED during subtraction to prevent MySQL crashes
        -- if processing temporarily dips below zero during math evaluation.
        -- ==============================================================
        IF(v_global_status = 'cancelled',
            -- If global order is cancelled, all items reflect as cancelled
            JSON_ARRAY(JSON_OBJECT('status', 'cancelled', 'qty', CAST(oi.quantity AS UNSIGNED))),
            
            -- Otherwise, calculate exact granular splits dynamically
            JSON_ARRAY(
                JSON_OBJECT('status', 'shipped', 'qty', CAST(COALESCE(f.shipped_qty, 0) AS UNSIGNED)),
                JSON_OBJECT('status', 'cancelled', 'qty', CAST(COALESCE(exc.cancelled_qty, 0) AS UNSIGNED)),
                JSON_OBJECT('status', 'issue_reported', 'qty', CAST(COALESCE(pending_exc.issue_qty, 0) AS UNSIGNED)),
                JSON_OBJECT('status', 'backordered', 'qty', CAST(COALESCE(bo_exc.bo_qty, 0) AS UNSIGNED)),
                JSON_OBJECT('status', 'processing', 'qty', CAST(GREATEST(0, CAST(COALESCE(a.routed_qty, 0) AS SIGNED) - CAST(COALESCE(f.shipped_qty, 0) AS SIGNED) - CAST(COALESCE(exc.cancelled_qty, 0) AS SIGNED) - CAST(COALESCE(pending_exc.issue_qty, 0) AS SIGNED) - CAST(COALESCE(bo_exc.bo_qty, 0) AS SIGNED)) AS UNSIGNED)),
                JSON_OBJECT('status', 'pending_routing', 'qty', CAST(GREATEST(0, CAST(oi.quantity AS SIGNED) - CAST(COALESCE(a.routed_qty, 0) AS SIGNED)) AS UNSIGNED))
            )
        ) AS allocations_json
        
    FROM order_items oi
    LEFT JOIN sku_master sm ON oi.product_id = sm.sku_id 
    LEFT JOIN sku_variant sv ON oi.variant_id = sv.variant_id
    LEFT JOIN categories c ON sm.category_id = c.category_id
    
    -- 1. Exact Shipped Quantities (DEDUPLICATED per store to fix double-click inflation)
    LEFT JOIN (
        SELECT order_item_id, SUM(store_shipped_qty) AS shipped_qty
        FROM (
            SELECT fi.order_item_id, off.store_id, MAX(fi.quantity_picked) AS store_shipped_qty
            FROM fulfillment_items fi
            JOIN order_fulfillments off ON fi.fulfillment_id = off.fulfillment_id
            WHERE off.order_id = p_order_id
            GROUP BY fi.order_item_id, off.store_id
        ) clean_f
        GROUP BY order_item_id
    ) f ON oi.order_item_id = f.order_item_id
    
    -- 2. Exact Cancelled Quantities (DEDUPLICATED per store)
    LEFT JOIN (
        SELECT product_id, variant_id, SUM(store_cancelled_qty) AS cancelled_qty
        FROM (
            SELECT product_id, variant_id, store_id, MAX(expected_qty - actual_picked_qty) AS store_cancelled_qty
            FROM inventory_exceptions
            WHERE order_id = p_order_id AND status = 'resolved' AND order_action = 'cancel'
            GROUP BY product_id, variant_id, store_id
        ) clean_exc
        GROUP BY product_id, variant_id
    ) exc ON oi.product_id = exc.product_id AND oi.variant_id <=> exc.variant_id
    
    -- 3. Exact Pending Exceptions / Issues Reported (DEDUPLICATED per store)
    LEFT JOIN (
        SELECT product_id, variant_id, SUM(store_issue_qty) AS issue_qty
        FROM (
            SELECT product_id, variant_id, store_id, MAX(expected_qty - actual_picked_qty) AS store_issue_qty
            FROM inventory_exceptions
            WHERE order_id = p_order_id AND status = 'pending'
            GROUP BY product_id, variant_id, store_id
        ) clean_pending_exc
        GROUP BY product_id, variant_id
    ) pending_exc ON oi.product_id = pending_exc.product_id AND oi.variant_id <=> pending_exc.variant_id

    -- 4. Exact Backordered Quantities (DEDUPLICATED per store)
    LEFT JOIN (
        SELECT product_id, variant_id, SUM(store_bo_qty) AS bo_qty
        FROM (
            SELECT product_id, variant_id, store_id, MAX(expected_qty - actual_picked_qty) AS store_bo_qty
            FROM inventory_exceptions
            WHERE order_id = p_order_id AND status = 'resolved' AND order_action = 'backorder'
            GROUP BY product_id, variant_id, store_id
        ) clean_bo_exc
        GROUP BY product_id, variant_id
    ) bo_exc ON oi.product_id = bo_exc.product_id AND oi.variant_id <=> bo_exc.variant_id
    
    -- 5. Total Routed Quantities (Sent to a warehouse floor - NOT duplicated because it's managed via UPDATE)
    LEFT JOIN (
        SELECT order_item_id, SUM(allocated_qty) AS routed_qty
        FROM order_allocations
        WHERE order_id = p_order_id
        GROUP BY order_item_id
    ) a ON oi.order_item_id = a.order_item_id
    
    WHERE oi.order_id = p_order_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetOrderRoutingDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetOrderRoutingDetails`(IN p_order_id BIGINT)
BEGIN
    -- Order Header
    SELECT o.order_id, o.order_number, o.total_amount, o.created_at, o.shipping_address, o.order_status,
           u.first_name, u.last_name, o.guest_email
    FROM orders o
    LEFT JOIN users u ON o.user_id = u.user_id
    WHERE o.order_id = p_order_id;
    
    -- Items & Live Network Stock Availability + Existing Allocations
    SELECT 
        oi.order_item_id, oi.product_id, oi.variant_id, oi.product_name, oi.quantity AS ordered_qty,
        COALESCE((SELECT SUM(allocated_qty) FROM order_allocations WHERE order_item_id = oi.order_item_id), 0) AS total_allocated,
        COALESCE(sv.sku, sm.sku) AS sku,
        COALESCE(sv.combination_key, '') AS variant_name,
        COALESCE(
            (SELECT media_url FROM sku_media WHERE sku_id = sm.sku_id AND (variant_id = oi.variant_id OR variant_id IS NULL) AND media_type = 'image' ORDER BY is_primary DESC LIMIT 1), 
            sm.image_url
        ) AS image_url,
        
        -- Crucial: Get Live Stock across all stores
        COALESCE((
            SELECT JSON_ARRAYAGG(JSON_OBJECT('store_id', si.store_id, 'store_name', s.name, 'store_code', s.store_code, 'stock', si.quantity))
            FROM sku_inventory si
            JOIN stores s ON si.store_id = s.store_id
            WHERE si.sku_id = oi.product_id AND si.variant_id <=> oi.variant_id AND si.quantity > 0 AND s.is_active = 1
        ), '[]') AS stock_availability,
        
        -- NEW FIX: Get existing allocations to display where it was routed
        COALESCE((
            SELECT JSON_ARRAYAGG(JSON_OBJECT('store_id', oa.store_id, 'store_name', s.name, 'store_code', s.store_code, 'qty', oa.allocated_qty))
            FROM order_allocations oa
            JOIN stores s ON oa.store_id = s.store_id
            WHERE oa.order_item_id = oi.order_item_id
        ), '[]') AS existing_allocations
        
    FROM order_items oi
    JOIN sku_master sm ON oi.product_id = sm.sku_id
    LEFT JOIN sku_variant sv ON oi.variant_id = sv.variant_id
    WHERE oi.order_id = p_order_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetPendingBackorders` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetPendingBackorders`(IN p_manager_id BIGINT)
BEGIN
    DECLARE v_store_id INT;
    SELECT store_id INTO v_store_id FROM user_store_mapping WHERE user_id = p_manager_id LIMIT 1;

    SELECT b.*, sm.name as product_name, sm.sku, COALESCE((SELECT combination_key FROM sku_variant WHERE variant_id = b.variant_id), 'Standard') as variant_name, o.order_number as original_order_number, u.first_name as buyer_name, u.last_name as buyer_last_name,
           COALESCE((SELECT quantity FROM sku_inventory WHERE store_id = v_store_id AND sku_id = b.product_id AND variant_id <=> b.variant_id), 0) as current_stock
    FROM backorders b
    JOIN orders o ON b.original_order_id = o.order_id
    JOIN users u ON o.user_id = u.user_id
    JOIN sku_master sm ON b.product_id = sm.sku_id
    WHERE b.store_id = v_store_id AND b.status = 'pending'
    ORDER BY b.created_at ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetProductAttributes` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetProductAttributes`(IN p_sku_id BIGINT)
BEGIN
    SELECT DISTINCT
        sa.attribute_id,
        sa.attribute_name,
        sav.value_id,
        sav.attribute_value,
        sav.color_code
    FROM sku_variant sv
    JOIN sku_variant_attributes sva ON sv.variant_id = sva.variant_id
    JOIN sku_attribute_values sav ON sva.value_id = sav.value_id
    JOIN sku_attributes sa ON sav.attribute_id = sa.attribute_id
    WHERE sv.sku_id = p_sku_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetProductDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetProductDetails`(IN p_sku_id BIGINT, IN p_user_id BIGINT, IN p_guest_id VARCHAR(255))
BEGIN
    SELECT 
        sm.sku_id AS product_id,
        sm.name, sm.description, sm.sku, sm.specifications, sm.warranty_info, sm.manufacturer_info, sm.product_definition,
        sm.is_grouped_product, sm.gtin, sm.manufacturer_part_number, sm.old_price, sm.product_cost, sm.disable_buy_button,
        sm.call_for_price, sm.weight, sm.length, sm.width, sm.height, sm.minimum_cart_qty, sm.maximum_cart_qty, sm.not_returnable, sm.case_pack_quantity,
        
        COALESCE((SELECT MIN(price) FROM sku_variant WHERE sku_id = sm.sku_id), sm.price, 0) AS price,
        COALESCE((SELECT media_url FROM sku_media WHERE sku_id = sm.sku_id AND media_type = 'image' AND variant_id IS NULL ORDER BY is_primary DESC, display_order ASC LIMIT 1), sm.image_url) AS image_url,
        c.name AS category_name, b.name AS brand_name,
        IF(EXISTS(SELECT 1 FROM sku_variant WHERE sku_id = sm.sku_id), 1, 0) AS has_variants,
        
        -- AGGREGATE STOCK GLOBALLY (Removed store_id dependency)
        COALESCE((SELECT SUM(quantity) FROM sku_inventory WHERE sku_id = sm.sku_id AND variant_id IS NULL), 0) AS stock_quantity,
        
        COALESCE(
            (SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id', sv.variant_id, 
                    'name', sv.combination_key, 
                    'sku', sv.sku,
                    'price', sv.price,
                    -- Fetch the exact variant image from the sku_media table
                    'image', COALESCE(
                        (SELECT media_url FROM sku_media WHERE sku_id = sm.sku_id AND variant_id = sv.variant_id AND media_type = 'image' ORDER BY is_primary DESC, display_order ASC LIMIT 1),
                        sv.image_url
                    ),
                    -- AGGREGATE VARIANT STOCK GLOBALLY (Removed store_id dependency and used SUM)
                    'stock', COALESCE((SELECT SUM(quantity) FROM sku_inventory si WHERE si.variant_id = sv.variant_id), 0),
                    
                    -- Fetch cart quantity globally (Removed cart.store_id)
                    'cart_quantity', COALESCE((
                        SELECT SUM(ci.quantity) FROM cart_items ci JOIN carts cart ON ci.cart_id = cart.cart_id 
                        WHERE ci.variant_id = sv.variant_id AND cart.status = 'active' 
                        AND ((p_user_id IS NOT NULL AND cart.user_id = p_user_id) OR (p_user_id IS NULL AND cart.session_id = p_guest_id))
                    ), 0)
                )
             ) FROM sku_variant sv WHERE sv.sku_id = sm.sku_id), '[]'
        ) AS variants_json,
        
        -- Fetch base cart quantity globally (Removed cart.store_id)
        COALESCE((
            SELECT SUM(ci.quantity) FROM cart_items ci JOIN carts cart ON ci.cart_id = cart.cart_id 
            WHERE ci.product_id = sm.sku_id AND ci.variant_id IS NULL AND cart.status = 'active' 
            AND ((p_user_id IS NOT NULL AND cart.user_id = p_user_id) OR (p_user_id IS NULL AND cart.session_id = p_guest_id))
        ), 0) AS base_cart_quantity,

        -- NEW FIX: Fetch Volume Tier Pricing and return as JSON Array
        COALESCE((
            SELECT JSON_ARRAYAGG(JSON_OBJECT('min_quantity', vp.min_quantity, 'price', vp.price))
            FROM (
                SELECT min_quantity, price 
                FROM sku_volume_pricing 
                WHERE sku_id = p_sku_id 
                ORDER BY min_quantity ASC
            ) vp
        ), '[]') AS volume_pricing,

        -- THE FIX: Expose the is_favorite column to the detail page!
        IF(p_user_id IS NOT NULL AND EXISTS(SELECT 1 FROM user_favorite_products WHERE user_id = p_user_id AND product_id = sm.sku_id), 1, 0) AS is_favorite

    FROM sku_master sm
    LEFT JOIN categories c ON sm.category_id = c.category_id
    LEFT JOIN brands b ON sm.brand_id = b.brand_id
    WHERE sm.sku_id = p_sku_id AND sm.is_active = 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetProductMedia` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetProductMedia`(IN p_sku_id BIGINT)
BEGIN
    SELECT 
        media_id,
        media_type,
        media_url
    FROM sku_media
    WHERE sku_id = p_sku_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetProductsByCategory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetProductsByCategory`(
    IN p_cat_id INT, 
    IN p_user_id BIGINT, 
    IN p_guest_id VARCHAR(255)
)
BEGIN
    SELECT 
        sm.sku_id AS product_id, sm.name, sm.description, sm.sku,
        COALESCE((SELECT MIN(price) FROM sku_variant WHERE sku_id = sm.sku_id), sm.price, 0) AS price,
        COALESCE((SELECT media_url FROM sku_media WHERE sku_id = sm.sku_id AND media_type = 'image' ORDER BY is_primary DESC, display_order ASC LIMIT 1), sm.image_url) AS image_url,
        c.name AS category_name, b.name AS brand_name,
        IF(EXISTS(SELECT 1 FROM sku_variant WHERE sku_id = sm.sku_id), 1, 0) AS has_variants,
        
        -- AGGREGATE STOCK GLOBALLY
        COALESCE((SELECT SUM(quantity) FROM sku_inventory WHERE sku_id = sm.sku_id), 0) AS stock_quantity,
        
        COALESCE(
            (SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'id', sv.variant_id, 'name', sv.combination_key, 'sku', sv.sku, 'price', sv.price,
                    -- THE FIX: Fetch from sku_media!
                    'image', COALESCE((SELECT media_url FROM sku_media WHERE sku_id = sm.sku_id AND variant_id = sv.variant_id AND media_type = 'image' ORDER BY is_primary DESC, display_order ASC LIMIT 1), sv.image_url),
                    
                    -- AGGREGATE VARIANT STOCK GLOBALLY
                    'stock', COALESCE((SELECT SUM(quantity) FROM sku_inventory si WHERE si.variant_id = sv.variant_id), 0),
                    
                    -- REMOVED cart.store_id = p_store_id
                    'cart_quantity', COALESCE((SELECT SUM(ci.quantity) FROM cart_items ci JOIN carts cart ON ci.cart_id = cart.cart_id WHERE ci.variant_id = sv.variant_id AND cart.status = 'active' AND ((p_user_id IS NOT NULL AND cart.user_id = p_user_id) OR (p_user_id IS NULL AND cart.session_id = p_guest_id))), 0)
                )
             ) FROM sku_variant sv WHERE sv.sku_id = sm.sku_id), '[]'
        ) AS variants_json,
        
        -- REMOVED cart.store_id = p_store_id
        COALESCE((SELECT SUM(ci.quantity) FROM cart_items ci JOIN carts cart ON ci.cart_id = cart.cart_id WHERE ci.product_id = sm.sku_id AND ci.variant_id IS NULL AND cart.status = 'active' AND ((p_user_id IS NOT NULL AND cart.user_id = p_user_id) OR (p_user_id IS NULL AND cart.session_id = p_guest_id))), 0) AS base_cart_quantity
        
    FROM sku_master sm
    LEFT JOIN categories c ON sm.category_id = c.category_id
    LEFT JOIN brands b ON sm.brand_id = b.brand_id
    WHERE sm.is_active = 1 AND sm.category_id = p_cat_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetProductVariants` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetProductVariants`(IN p_sku_id BIGINT)
BEGIN
    SELECT 
        sv.combination_key,
        sv.variant_id,
        sv.price,
        -- Aggregate stock across stores for display purposes, 
        -- actual block/lock happens in the Cart Update SP per store
        COALESCE((SELECT SUM(quantity) FROM sku_inventory WHERE sku_id = p_sku_id), 0) AS stock_quantity,
        sv.sku,
        sv.image_url
    FROM sku_variant sv
    WHERE sv.sku_id = p_sku_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetResolvedWarehouseExceptions` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetResolvedWarehouseExceptions`(IN p_manager_id BIGINT)
BEGIN
    DECLARE v_store_id INT;
    SELECT store_id INTO v_store_id FROM user_store_mapping WHERE user_id = p_manager_id LIMIT 1;
    
    SELECT e.*, o.order_number, sm.name AS product_name, sm.sku, u_reporter.first_name as worker_name, u_resolver.first_name as manager_name
    FROM inventory_exceptions e
    JOIN orders o ON e.order_id = o.order_id
    -- THE FIX: The column in inventory_exceptions is product_id, not sku_id
    JOIN sku_master sm ON e.product_id = sm.sku_id
    LEFT JOIN users u_reporter ON e.reported_by = u_reporter.user_id
    LEFT JOIN users u_resolver ON e.resolved_by = u_resolver.user_id
    WHERE e.store_id = v_store_id AND e.status = 'resolved'
    ORDER BY e.updated_at DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetServicingWarehouses` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetServicingWarehouses`()
BEGIN
    SELECT store_id, store_name, store_code
    FROM stores
    WHERE store_type = 'warehouse' OR store_type IS NULL OR store_type = '';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetStoreHierarchy` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetStoreHierarchy`()
BEGIN
    SELECT 
        r.region_id, r.name AS region_name,
        a.area_id, a.name AS area_name,
        s.store_id, s.name AS store_name, s.store_code,
        s.min_order_value, s.max_order_value, s.approval_threshold
    FROM regions r
    LEFT JOIN areas a ON r.region_id = a.region_id
    LEFT JOIN stores s ON a.area_id = s.area_id
    ORDER BY r.name, a.name, s.name;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetStoreSettings` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetStoreSettings`(IN p_store_id INT)
BEGIN
    SELECT min_order_value, max_order_value, approval_threshold 
    FROM stores 
    WHERE store_id = p_store_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetSystemUsers` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetSystemUsers`()
BEGIN
    SELECT 
        u.user_id, u.first_name, u.last_name, u.email, u.user_type, u.is_active,
        urm.restaurant_id, r.restaurant_name, r.restaurant_code,
        usm.store_id, s.name AS warehouse_name, s.store_code
    FROM users u
    -- Join restaurants via the restaurant mapping table
    LEFT JOIN user_restaurant_mapping urm ON u.user_id = urm.user_id
    LEFT JOIN restaurants r ON urm.restaurant_id = r.restaurant_id
    -- NEW: Join warehouses via the store mapping table!
    LEFT JOIN user_store_mapping usm ON u.user_id = usm.user_id
    LEFT JOIN stores s ON usm.store_id = s.store_id
    WHERE u.user_type IN ('admin', 'helpdesk', 'restaurant', 'warehouse_manager', 'warehouse_worker')
    ORDER BY u.created_at DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetUserAddresses` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserAddresses`(IN p_user_id BIGINT)
BEGIN
    SELECT * FROM user_addresses WHERE user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetUserAuth` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserAuth`(
    IN p_username VARCHAR(50)
)
BEGIN
    SELECT id, username, password_hash 
    FROM users 
    WHERE username = p_username;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetUserByEmail` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserByEmail`(IN p_email VARCHAR(255))
BEGIN
    SELECT u.user_id, u.first_name, u.last_name, u.email, u.password_hash, 
           u.user_type, u.assigned_store_id,
           s.name AS store_name, -- Fetch the specific warehouse name
           -- Hierarchy Check: Does this user have manager access in ANY store?
           (SELECT COUNT(*) FROM user_store_access usa 
            WHERE usa.user_id = u.user_id 
              AND usa.role IN ('store_manager', 'regional_manager')) > 0 AS is_manager
    FROM users u
    LEFT JOIN stores s ON u.assigned_store_id = s.store_id
    WHERE u.email = p_email AND u.is_active = 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetUserOrders` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserOrders`(IN p_user_id INT)
BEGIN
    SELECT * FROM orders 
    WHERE user_id = p_user_id 
    ORDER BY created_at DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetUserPhone` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserPhone`(IN p_user_id INT)
BEGIN
    SELECT phone FROM users WHERE user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetUserProfile` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserProfile`(IN p_user_id INT)
BEGIN
    SELECT user_id, first_name, last_name, email, phone, created_at 
    FROM users 
    WHERE user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetUserRestaurantTag` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserRestaurantTag`(IN p_user_id BIGINT)
BEGIN
    SELECT r.restaurant_name, r.restaurant_code
    FROM user_restaurant_mapping urm
    JOIN restaurants r ON urm.restaurant_id = r.restaurant_id
    WHERE urm.user_id = p_user_id
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetUserTaxRate` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserTaxRate`(IN p_user_id BIGINT)
BEGIN
    SELECT COALESCE(r.tax_rate, 0.00) AS tax_rate
    FROM user_restaurant_mapping urm
    JOIN restaurants r ON urm.restaurant_id = r.restaurant_id
    WHERE urm.user_id = p_user_id
    LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetVariantCartQuantities` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetVariantCartQuantities`(
    IN p_sku_id BIGINT, 
    IN p_user_id BIGINT, 
    IN p_session_id VARCHAR(255)
)
BEGIN
    SELECT 
        ci.variant_id,
        ci.quantity
    FROM cart_items ci
    JOIN carts c ON ci.cart_id = c.cart_id
    WHERE ci.product_id = p_sku_id
      AND c.status = 'active'
      AND (
          (p_user_id IS NOT NULL AND c.user_id = p_user_id)
          OR
          (p_user_id IS NULL AND c.session_id = p_session_id)
      );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetVariantIdByCombo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetVariantIdByCombo`(IN p_sku_id BIGINT, IN p_combo_key VARCHAR(255))
BEGIN
    SELECT variant_id FROM sku_variant 
    WHERE sku_id = p_sku_id AND combination_key = p_combo_key LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetVariantIdBySku` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetVariantIdBySku`(IN p_sku_id BIGINT, IN p_sku VARCHAR(100))
BEGIN
    SELECT variant_id FROM sku_variant 
    WHERE sku_id = p_sku_id AND sku = p_sku LIMIT 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetWarehouseDashboardStats` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetWarehouseDashboardStats`(IN p_manager_id BIGINT)
BEGIN
    DECLARE v_store_id INT;
    
    -- ZERO TRUST: Lookup warehouse mapping dynamically
    SELECT store_id INTO v_store_id FROM user_store_mapping WHERE user_id = p_manager_id LIMIT 1;
    
    -- RESULT SET 1: KPI Stat Cards
    SELECT 
        (SELECT COUNT(DISTINCT order_id) FROM order_allocations WHERE store_id = v_store_id AND DATE(created_at) = CURDATE()) AS new_orders,
        (SELECT COUNT(DISTINCT oa.order_id) FROM order_allocations oa JOIN orders o ON oa.order_id = o.order_id WHERE oa.store_id = v_store_id AND o.order_status IN ('pending', 'confirmed', 'processing') AND oa.assigned_worker_id IS NULL) AS action_needed,
        (SELECT COUNT(DISTINCT oa.order_id) FROM order_allocations oa JOIN orders o ON oa.order_id = o.order_id WHERE oa.store_id = v_store_id AND o.order_status = 'shipped' AND DATE(o.created_at) = CURDATE()) AS shipped_today,
        (SELECT COUNT(*) FROM sku_inventory WHERE store_id = v_store_id AND quantity <= COALESCE(low_stock_threshold, 0)) AS low_stock_alerts,
        (SELECT COUNT(*) FROM inventory_exceptions WHERE store_id = v_store_id AND status = 'pending') AS short_picks;

    -- RESULT SET 2: Master Queue - "Action Needed / Inbox"
    SELECT 
        o.order_id, o.order_number, o.created_at, o.order_status, 
        oa.assigned_worker_id, u.first_name, u.last_name,
        SUM(oa.allocated_qty) AS total_items
    FROM orders o
    LEFT JOIN users u ON o.user_id = u.user_id
    JOIN order_allocations oa ON o.order_id = oa.order_id
    WHERE oa.store_id = v_store_id 
      AND o.order_status IN ('pending', 'confirmed', 'processing')
      AND oa.assigned_worker_id IS NULL
    GROUP BY o.order_id, o.order_number, o.created_at, o.order_status, oa.assigned_worker_id, u.first_name, u.last_name
    ORDER BY o.created_at ASC;

    -- RESULT SET 3: Master Queue - "Active on Floor"
    SELECT 
        o.order_id, o.order_number, o.created_at, o.order_status, 
        oa.assigned_worker_id, u.first_name, u.last_name,
        COALESCE(w.first_name, 'Assigned') AS worker_first_name,
        SUM(oa.allocated_qty) AS total_items
    FROM orders o
    LEFT JOIN users u ON o.user_id = u.user_id
    JOIN order_allocations oa ON o.order_id = oa.order_id
    LEFT JOIN users w ON oa.assigned_worker_id = w.user_id
    WHERE oa.store_id = v_store_id 
      AND o.order_status IN ('processing', 'partially_shipped')
      AND oa.assigned_worker_id IS NOT NULL
    GROUP BY o.order_id, o.order_number, o.created_at, o.order_status, oa.assigned_worker_id, u.first_name, u.last_name, worker_first_name
    ORDER BY o.created_at DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetWarehouseExceptions` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetWarehouseExceptions`(IN p_manager_id BIGINT)
BEGIN
    DECLARE v_store_id INT;
    SELECT store_id INTO v_store_id FROM user_store_mapping WHERE user_id = p_manager_id LIMIT 1;
    
    SELECT e.*, o.order_number, sm.name AS product_name, u.first_name, u.last_name
    FROM inventory_exceptions e
    JOIN orders o ON e.order_id = o.order_id
    -- THE FIX: The column in inventory_exceptions is product_id, not sku_id
    JOIN sku_master sm ON e.product_id = sm.sku_id
    LEFT JOIN users u ON e.reported_by = u.user_id
    WHERE e.store_id = v_store_id AND e.status = 'pending'
    ORDER BY e.created_at DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetWarehouseOrderDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetWarehouseOrderDetails`(IN p_order_id BIGINT, IN p_user_id BIGINT)
BEGIN
    DECLARE v_store_id INT;
    SELECT store_id INTO v_store_id FROM user_store_mapping WHERE user_id = p_user_id LIMIT 1;
    
    SELECT DISTINCT o.order_id, o.order_number, o.created_at, o.order_status, o.total_amount, u.first_name, u.last_name, COALESCE(u.email, o.guest_email) AS email
    FROM orders o LEFT JOIN users u ON o.user_id = u.user_id JOIN order_allocations oa ON o.order_id = oa.order_id
    WHERE o.order_id = p_order_id AND oa.store_id = v_store_id;

    SELECT oi.order_item_id, oa.allocated_qty AS quantity, oi.price, sm.name AS product_name, COALESCE(sv.sku, sm.sku) AS sku, COALESCE(sv.combination_key, 'Standard') AS variant_name, COALESCE((SELECT media_url FROM sku_media WHERE sku_id = sm.sku_id AND (variant_id = oi.variant_id OR variant_id IS NULL) AND media_type = 'image' ORDER BY is_primary DESC, display_order ASC LIMIT 1), sm.image_url) AS image_url
    FROM order_items oi JOIN order_allocations oa ON oi.order_item_id = oa.order_item_id JOIN sku_master sm ON oi.product_id = sm.sku_id LEFT JOIN sku_variant sv ON oi.variant_id = sv.variant_id
    WHERE oi.order_id = p_order_id AND oa.store_id = v_store_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetWarehouseWorkers` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetWarehouseWorkers`(IN p_manager_id BIGINT)
BEGIN
    DECLARE v_store_id INT;
    SELECT store_id INTO v_store_id FROM user_store_mapping WHERE user_id = p_manager_id LIMIT 1;
    
    SELECT u.user_id, u.first_name, u.last_name, u.email, u.phone, u.is_active, u.created_at 
    FROM users u 
    JOIN user_store_mapping usm ON u.user_id = usm.user_id
    WHERE usm.store_id = v_store_id AND u.user_type IN ('warehouse_worker')
    ORDER BY u.is_active DESC, u.first_name ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetWorkerCompletedTasks` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetWorkerCompletedTasks`(IN p_worker_id BIGINT)
BEGIN
    DECLARE v_store_id INT;
    
    -- Securely find the worker's assigned warehouse
    SELECT store_id INTO v_store_id FROM user_store_mapping WHERE user_id = p_worker_id LIMIT 1;
    
    -- Fetch the completed orders and bundle their EXACT packed items into JSON
    SELECT 
        o.order_id, 
        o.order_number, 
        COALESCE(o.updated_at, o.created_at) AS completed_at,
        oa_group.total_items,
        COALESCE((
            SELECT JSON_ARRAYAGG(
                JSON_OBJECT(
                    'product_name', sm.name,
                    'sku', COALESCE(sv.sku, sm.sku),
                    'variant_name', COALESCE(sv.combination_key, 'Standard'),
                    -- Output both the EXACT picked quantity AND the original allocated quantity
                    'quantity', CAST(fi.quantity_picked AS UNSIGNED),
                    'allocated_qty', CAST(oa_items.allocated_qty AS UNSIGNED),
                    'image_url', COALESCE(
                        (SELECT media_url FROM sku_media 
                         WHERE sku_id = sm.sku_id 
                           AND (variant_id = oi.variant_id OR variant_id IS NULL) 
                           AND media_type = 'image' 
                         ORDER BY is_primary DESC LIMIT 1), 
                        sm.image_url
                    )
                )
            )
            FROM order_allocations oa_items
            JOIN order_items oi ON oa_items.order_item_id = oi.order_item_id
            JOIN sku_master sm ON oi.product_id = sm.sku_id
            LEFT JOIN sku_variant sv ON oi.variant_id = sv.variant_id
            
            -- Deep join into physical fulfillments (with deduplication for double-clicks)
            JOIN (
                SELECT fi.order_item_id, MAX(fi.quantity_picked) as quantity_picked
                FROM fulfillment_items fi
                JOIN order_fulfillments off ON fi.fulfillment_id = off.fulfillment_id
                WHERE off.store_id = v_store_id AND off.order_id = o.order_id
                GROUP BY fi.order_item_id
            ) fi ON fi.order_item_id = oa_items.order_item_id
            
            WHERE oa_items.order_id = o.order_id 
              AND oa_items.store_id = v_store_id 
              AND oa_items.assigned_worker_id = p_worker_id
              AND oa_items.status IN ('shipped', 'partially_shipped')
              -- Only show items they ACTUALLY put in the box (hides complete short-picks)
              AND fi.quantity_picked > 0
        ), '[]') AS items_json
    FROM orders o
    
    -- Recalculate the master header total using only the true packed items
    JOIN (
        SELECT oa.order_id, SUM(fi.quantity_picked) AS total_items
        FROM order_allocations oa
        JOIN (
            SELECT fi.order_item_id, MAX(fi.quantity_picked) as quantity_picked
            FROM fulfillment_items fi
            JOIN order_fulfillments off ON fi.fulfillment_id = off.fulfillment_id
            WHERE off.store_id = v_store_id
            GROUP BY fi.order_item_id
        ) fi ON fi.order_item_id = oa.order_item_id
        WHERE oa.store_id = v_store_id
          AND oa.assigned_worker_id = p_worker_id
          AND oa.status IN ('shipped', 'partially_shipped')
        GROUP BY oa.order_id
    ) oa_group ON o.order_id = oa_group.order_id
    
    ORDER BY completed_at DESC
    LIMIT 100;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetWorkerDashboardStats` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetWorkerDashboardStats`(IN p_worker_id BIGINT)
BEGIN
    DECLARE v_store_id INT;
    SELECT store_id INTO v_store_id FROM user_store_mapping WHERE user_id = p_worker_id LIMIT 1;
    
    SELECT 
        (SELECT COUNT(DISTINCT oa.order_id) FROM order_allocations oa JOIN orders o ON oa.order_id = o.order_id 
         WHERE oa.store_id = v_store_id AND o.order_status IN ('processing', 'partially_shipped') 
         AND oa.status NOT IN ('shipped', 'cancelled') -- FIX 
         AND (oa.assigned_worker_id = p_worker_id OR oa.assigned_worker_id = 0)) AS action_needed,
         
        (SELECT COUNT(DISTINCT oa.order_id) FROM order_allocations oa JOIN orders o ON oa.order_id = o.order_id 
         WHERE oa.store_id = v_store_id AND oa.status = 'shipped' AND DATE(o.updated_at) = CURDATE()) AS shipped_today,
         
        0 AS new_orders, 0 AS low_stock_alerts, 0 AS short_picks;

    SELECT o.order_id, o.order_number, o.created_at, o.order_status, oa.assigned_worker_id, u.first_name, u.last_name, SUM(oa.allocated_qty) AS total_items
    FROM orders o
    LEFT JOIN users u ON o.user_id = u.user_id
    JOIN order_allocations oa ON o.order_id = oa.order_id
    WHERE oa.store_id = v_store_id 
      AND o.order_status IN ('processing', 'partially_shipped') 
      AND oa.status NOT IN ('shipped', 'cancelled') -- FIX
      AND (oa.assigned_worker_id = p_worker_id OR oa.assigned_worker_id = 0)
    GROUP BY o.order_id, o.order_number, o.created_at, o.order_status, oa.assigned_worker_id, u.first_name, u.last_name
    ORDER BY CASE WHEN oa.assigned_worker_id = p_worker_id THEN 1 ELSE 2 END, o.created_at ASC LIMIT 5;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetWorkerTasks` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetWorkerTasks`(IN p_worker_id BIGINT)
BEGIN
    DECLARE v_store_id INT;
    SELECT store_id INTO v_store_id FROM user_store_mapping WHERE user_id = p_worker_id LIMIT 1;
    
    SELECT 
        o.order_id, o.order_number, o.created_at, o.order_status, 
        oa.assigned_worker_id, u.first_name, u.last_name, 
        SUM(oa.allocated_qty) AS total_items
    FROM orders o
    LEFT JOIN users u ON o.user_id = u.user_id
    JOIN order_allocations oa ON o.order_id = oa.order_id
    WHERE oa.store_id = v_store_id 
      AND o.order_status IN ('processing', 'partially_shipped') 
      -- THE FIX: Exclude items that THIS warehouse has already shipped
      AND oa.status NOT IN ('shipped', 'cancelled') 
      AND (oa.assigned_worker_id = p_worker_id OR oa.assigned_worker_id = 0)
    GROUP BY o.order_id, o.order_number, o.created_at, o.order_status, oa.assigned_worker_id, u.first_name, u.last_name
    ORDER BY CASE WHEN oa.assigned_worker_id = p_worker_id THEN 1 ELSE 2 END, o.created_at ASC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `HelpdeskUpdateOrderStatus` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `HelpdeskUpdateOrderStatus`(IN p_order_id BIGINT, IN p_status VARCHAR(50))
BEGIN
    -- Override the main order status
    UPDATE orders 
    SET order_status = p_status, 
        updated_at = NOW() 
    WHERE order_id = p_order_id;
    
    -- If marked as delivered, sync the physical fulfillment box too
    IF p_status = 'delivered' THEN
        UPDATE order_fulfillments 
        SET status = 'delivered' 
        WHERE order_id = p_order_id;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `MarkOrderProcessing` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `MarkOrderProcessing`(IN p_order_id BIGINT)
BEGIN
    UPDATE orders SET order_status = 'processing' WHERE order_id = p_order_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `MergeCarts` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `MergeCarts`(
    IN p_guest_session_id VARCHAR(255),
    IN p_target_user_id INT
)
BEGIN
    DECLARE v_guest_cart_id INT;
    DECLARE v_user_cart_id INT;

    -- 1. Find the active Guest Cart ID
    SELECT cart_id INTO v_guest_cart_id 
    FROM carts 
    WHERE session_id = p_guest_session_id AND status = 'active' 
    LIMIT 1;

    -- 2. Find the active User Cart ID
    SELECT cart_id INTO v_user_cart_id 
    FROM carts 
    WHERE user_id = p_target_user_id AND status = 'active' 
    LIMIT 1;

    -- Scenario: Guest has a cart
    IF v_guest_cart_id IS NOT NULL THEN
        
        -- Case A: User has NO existing cart. 
        -- Simply take ownership of the guest cart.
        IF v_user_cart_id IS NULL THEN
            UPDATE carts 
            SET user_id = p_target_user_id, 
                session_id = NULL,
                updated_at = CURRENT_TIMESTAMP
            WHERE cart_id = v_guest_cart_id;
            
        -- Case B: Both have carts. Merge items.
        ELSE
            -- 1. Update User's existing items (add quantities from guest items)
            UPDATE cart_items ui
            JOIN cart_items gi ON ui.product_id = gi.product_id
            SET ui.quantity = ui.quantity + gi.quantity
            WHERE ui.cart_id = v_user_cart_id 
              AND gi.cart_id = v_guest_cart_id;

            -- 2. Delete the guest items that were just merged (duplicates)
            DELETE gi FROM cart_items gi
            INNER JOIN cart_items ui ON ui.product_id = gi.product_id
            WHERE ui.cart_id = v_user_cart_id 
              AND gi.cart_id = v_guest_cart_id;

            -- 3. Move remaining guest items (unique products) to the user cart
            UPDATE cart_items
            SET cart_id = v_user_cart_id,
                updated_at = CURRENT_TIMESTAMP
            WHERE cart_id = v_guest_cart_id;

            -- 4. Delete the now-empty Guest Cart header
            DELETE FROM carts WHERE cart_id = v_guest_cart_id;
            
        END IF;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `PlaceOrder` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `PlaceOrder`(
    IN p_user_id BIGINT,
    IN p_session_id VARCHAR(255),
    IN p_shipping_address TEXT,
    IN p_billing_address TEXT,
    IN p_total_amount DECIMAL(10,2),
    IN p_guest_email VARCHAR(255),
    IN p_guest_phone VARCHAR(50)
)
BEGIN
    DECLARE v_cart_id INT;
    DECLARE v_order_id INT;
    DECLARE v_order_number VARCHAR(50);
    
    -- Generate unique order number
    SET v_order_number = CONCAT('ORD-', DATE_FORMAT(NOW(), '%Y%m%d%H%i%s'), '-', LPAD(FLOOR(RAND() * 1000), 3, '0'));

    -- Find active cart
    SELECT cart_id INTO v_cart_id
    FROM carts
    WHERE status = 'active'
      AND ((p_user_id IS NOT NULL AND user_id = p_user_id) OR (p_user_id IS NULL AND session_id = p_session_id))
    LIMIT 1;

    IF v_cart_id IS NOT NULL THEN
        -- Insert Order (Notice we completely removed store_id)
        INSERT INTO orders (
            user_id, session_id, order_number, total_amount, order_status, 
            shipping_address, billing_address, guest_email, guest_phone
        ) VALUES (
            p_user_id, p_session_id, v_order_number, p_total_amount, 'pending', 
            p_shipping_address, p_billing_address, p_guest_email, p_guest_phone
        );
        
        SET v_order_id = LAST_INSERT_ID();

        -- Move items from cart to order
        INSERT INTO order_items (order_id, product_id, variant_id, quantity, price)
        SELECT v_order_id, product_id, variant_id, quantity, price
        FROM cart_items
        WHERE cart_id = v_cart_id;

        -- Close cart
        UPDATE carts SET status = 'converted' WHERE cart_id = v_cart_id;
        
        SELECT v_order_number AS order_number, v_order_id AS order_id;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cart is empty or not found';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ProcessOrderFulfillment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `ProcessOrderFulfillment`(IN p_order_id BIGINT, IN p_new_status VARCHAR(50), IN p_items_json JSON, IN p_worker_id BIGINT)
BEGIN
    DECLARE v_store_id INT;
    DECLARE v_fulfillment_id BIGINT;
    DECLARE i INT DEFAULT 0;
    DECLARE v_item_count INT;
    DECLARE v_order_item_id BIGINT;
    DECLARE v_picked_qty INT;
    DECLARE v_requested_qty INT;
    DECLARE v_prod_id BIGINT;
    DECLARE v_var_id BIGINT;
    DECLARE v_total_allocs INT;
    DECLARE v_shipped_allocs INT;
    
    SELECT store_id INTO v_store_id FROM user_store_mapping WHERE user_id = p_worker_id LIMIT 1;
    
    IF v_store_id IS NOT NULL THEN
        -- 1. Update THIS warehouse's allocation line
        UPDATE order_allocations SET status = p_new_status WHERE order_id = p_order_id AND store_id = v_store_id;
        
        -- 2. Process packed items & physical inventory reduction
        IF p_new_status IN ('shipped', 'partially_shipped') AND p_items_json IS NOT NULL THEN
            INSERT INTO order_fulfillments (order_id, store_id, status) VALUES (p_order_id, v_store_id, p_new_status);
            SET v_fulfillment_id = LAST_INSERT_ID();
            SET v_item_count = JSON_LENGTH(p_items_json);

            WHILE i < v_item_count DO
                SET v_order_item_id = JSON_UNQUOTE(JSON_EXTRACT(p_items_json, CONCAT('$[', i, '].order_item_id')));
                SET v_picked_qty = JSON_UNQUOTE(JSON_EXTRACT(p_items_json, CONCAT('$[', i, '].picked_quantity')));

                SELECT allocated_qty INTO v_requested_qty FROM order_allocations WHERE order_item_id = v_order_item_id AND store_id = v_store_id;
                SELECT product_id, variant_id INTO v_prod_id, v_var_id FROM order_items WHERE order_item_id = v_order_item_id;

                IF v_picked_qty > 0 THEN
                    INSERT INTO fulfillment_items (fulfillment_id, order_item_id, product_id, variant_id, quantity_picked) VALUES (v_fulfillment_id, v_order_item_id, v_prod_id, v_var_id, v_picked_qty);
                    UPDATE sku_inventory SET quantity = GREATEST(0, quantity - v_picked_qty), updated_at = CURRENT_TIMESTAMP WHERE store_id = v_store_id AND sku_id = v_prod_id AND variant_id <=> v_var_id;
                END IF;

                IF v_picked_qty < v_requested_qty THEN
                    INSERT INTO inventory_exceptions (store_id, order_id, product_id, variant_id, reported_by, expected_qty, actual_picked_qty)
                    VALUES (v_store_id, p_order_id, v_prod_id, v_var_id, p_worker_id, v_requested_qty, v_picked_qty);
                END IF;
                SET i = i + 1;
            END WHILE;
        END IF;

        -- 3. DOM SMART GLOBAL ORDER STATUS CALCULATION
        SELECT COUNT(*) INTO v_total_allocs FROM order_allocations WHERE order_id = p_order_id;
        SELECT COUNT(*) INTO v_shipped_allocs FROM order_allocations WHERE order_id = p_order_id AND status IN ('shipped', 'partially_shipped');
        
        IF v_total_allocs > 0 AND v_total_allocs = v_shipped_allocs THEN
            UPDATE orders SET order_status = 'shipped', updated_at = CURRENT_TIMESTAMP WHERE order_id = p_order_id;
        ELSEIF v_shipped_allocs > 0 THEN
            UPDATE orders SET order_status = 'partially_shipped', updated_at = CURRENT_TIMESTAMP WHERE order_id = p_order_id;
        END IF;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `RegisterUser` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `RegisterUser`(
    IN p_first_name VARCHAR(100),
    IN p_last_name VARCHAR(100),
    IN p_email VARCHAR(255),
    IN p_password_hash VARCHAR(255),
    IN p_phone VARCHAR(20)
)
BEGIN
    INSERT INTO users (first_name, last_name, email, password_hash, phone)
    VALUES (p_first_name, p_last_name, p_email, p_password_hash, p_phone);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ReleaseBackorderToFloor` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `ReleaseBackorderToFloor`(IN p_backorder_id BIGINT, IN p_manager_id BIGINT)
BEGIN
    DECLARE v_store_id INT;
    DECLARE v_orig_order_id BIGINT; 
    DECLARE v_new_order_id BIGINT;
    DECLARE v_new_order_item_id BIGINT;
    DECLARE v_prod_id BIGINT; 
    DECLARE v_var_id BIGINT; 
    DECLARE v_qty INT;
    DECLARE v_user_id BIGINT; 
    DECLARE v_orig_order_num VARCHAR(50);
    DECLARE v_prod_name VARCHAR(255);
    DECLARE v_ship_addr TEXT;
    DECLARE v_bill_addr TEXT;

    SELECT store_id INTO v_store_id FROM user_store_mapping WHERE user_id = p_manager_id LIMIT 1;
    
    IF v_store_id IS NOT NULL THEN
        SELECT original_order_id, product_id, variant_id, quantity INTO v_orig_order_id, v_prod_id, v_var_id, v_qty
        FROM backorders WHERE backorder_id = p_backorder_id AND store_id = v_store_id;

        SELECT user_id, order_number, shipping_address, billing_address INTO v_user_id, v_orig_order_num, v_ship_addr, v_bill_addr
        FROM orders WHERE order_id = v_orig_order_id;
        SELECT name INTO v_prod_name FROM sku_master WHERE sku_id = v_prod_id;

        -- Create new Global Order for the backordered slice
        INSERT INTO orders (user_id, order_number, order_status, total_amount, shipping_address, billing_address)
        VALUES (v_user_id, CONCAT(v_orig_order_num, '-B'), 'processing', 0.00, v_ship_addr, v_bill_addr);
        SET v_new_order_id = LAST_INSERT_ID();

        INSERT INTO order_items (order_id, product_id, variant_id, product_name, quantity, price)
        VALUES (v_new_order_id, v_prod_id, v_var_id, v_prod_name, v_qty, 0.00);
        SET v_new_order_item_id = LAST_INSERT_ID();

        -- Drop it instantly into this warehouse's local Master Queue (order_allocations)
        INSERT INTO order_allocations (order_id, order_item_id, store_id, allocated_qty, status)
        VALUES (v_new_order_id, v_new_order_item_id, v_store_id, v_qty, 'allocated');

        UPDATE backorders SET status = 'released' WHERE backorder_id = p_backorder_id;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ResolveWarehouseException` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `ResolveWarehouseException`(
    IN p_exception_id BIGINT, IN p_manager_id BIGINT, IN p_inventory_action VARCHAR(50), 
    IN p_manager_count INT, IN p_reason_code VARCHAR(100), IN p_order_action VARCHAR(50), IN p_notes TEXT
)
BEGIN
    DECLARE v_store_id INT;
    DECLARE v_product_id BIGINT;
    DECLARE v_variant_id BIGINT;
    DECLARE v_order_id BIGINT;
    DECLARE v_expected_qty INT;
    DECLARE v_actual_picked_qty INT;

    SELECT store_id INTO v_store_id FROM user_store_mapping WHERE user_id = p_manager_id LIMIT 1;
    
    IF v_store_id IS NOT NULL THEN
        SELECT product_id, variant_id, order_id, expected_qty, actual_picked_qty INTO v_product_id, v_variant_id, v_order_id, v_expected_qty, v_actual_picked_qty
        FROM inventory_exceptions WHERE exception_id = p_exception_id AND store_id = v_store_id;

        UPDATE sku_inventory SET quantity = p_manager_count, updated_at = CURRENT_TIMESTAMP WHERE store_id = v_store_id AND sku_id = v_product_id AND variant_id <=> v_variant_id;
        
        UPDATE inventory_exceptions 
        SET status = 'resolved', resolved_by = p_manager_id, inventory_action = p_inventory_action, manager_count = p_manager_count, reason_code = p_reason_code, order_action = p_order_action, resolution_notes = p_notes, updated_at = CURRENT_TIMESTAMP
        WHERE exception_id = p_exception_id AND store_id = v_store_id;

        IF p_order_action = 'backorder' THEN
            INSERT INTO backorders (store_id, original_order_id, product_id, variant_id, quantity)
            VALUES (v_store_id, v_order_id, v_product_id, v_variant_id, (v_expected_qty - v_actual_picked_qty));
        END IF;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SaveSystemUser` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SaveSystemUser`(
    IN p_user_id BIGINT,
    IN p_first_name VARCHAR(100),
    IN p_last_name VARCHAR(100),
    IN p_email VARCHAR(255),
    IN p_password VARCHAR(255),
    IN p_user_type VARCHAR(50),
    IN p_restaurant_id INT,
    IN p_store_id INT
)
BEGIN
    DECLARE v_user_id BIGINT;

    IF p_user_id IS NULL OR p_user_id = 0 THEN
        -- Insert user (Removed direct store_id and restaurant_id inserts)
        INSERT INTO users (first_name, last_name, email, password_hash, user_type)
        VALUES (p_first_name, p_last_name, p_email, p_password, p_user_type);
        SET v_user_id = LAST_INSERT_ID();
    ELSE
        SET v_user_id = p_user_id;
        
        -- Update existing user
        UPDATE users
        SET first_name = p_first_name,
            last_name = p_last_name,
            email = p_email,
            user_type = p_user_type
        WHERE user_id = v_user_id;
        
        -- Only update password if a new one was provided
        IF p_password IS NOT NULL AND p_password != '' THEN
            UPDATE users SET password_hash = p_password WHERE user_id = v_user_id;
        END IF;
    END IF;

    -- ==========================================
    -- MANAGE RESTAURANT TAGS
    -- ==========================================
    DELETE FROM user_restaurant_mapping WHERE user_id = v_user_id;
    
    IF p_user_type = 'restaurant' AND p_restaurant_id IS NOT NULL AND p_restaurant_id > 0 THEN
        INSERT INTO user_restaurant_mapping (user_id, restaurant_id)
        VALUES (v_user_id, p_restaurant_id);
    END IF;

    -- ==========================================
    -- NEW: MANAGE WAREHOUSE TAGS
    -- ==========================================
    DELETE FROM user_store_mapping WHERE user_id = v_user_id;
    
    IF p_user_type IN ('warehouse_manager', 'warehouse_worker') AND p_store_id IS NOT NULL AND p_store_id > 0 THEN
        INSERT INTO user_store_mapping (user_id, store_id)
        VALUES (v_user_id, p_store_id);
    END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SearchProducts` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SearchProducts`(IN p_query VARCHAR(255), IN p_cat_id INT, IN p_brand_id INT, IN p_min_price DECIMAL(10,2), IN p_max_price DECIMAL(10,2))
BEGIN
    SELECT 
        sm.sku_id AS product_id, sm.name, sm.description, sm.sku,
        (SELECT GROUP_CONCAT(sku SEPARATOR ', ') FROM sku_variant WHERE sku_id = sm.sku_id) AS variant_skus,
        COALESCE((SELECT MIN(price) FROM sku_variant WHERE sku_id = sm.sku_id), sm.price, 0) AS price,
        COALESCE((SELECT media_url FROM sku_media WHERE sku_id = sm.sku_id AND media_type = 'image' ORDER BY is_primary DESC, display_order ASC LIMIT 1), sm.image_url) AS image_url,
        c.name AS category_name, b.name AS brand_name,
        IF(EXISTS(SELECT 1 FROM sku_variant WHERE sku_id = sm.sku_id), 1, 0) AS has_variants
    FROM sku_master sm
    LEFT JOIN categories c ON sm.category_id = c.category_id
    LEFT JOIN brands b ON sm.brand_id = b.brand_id
    WHERE sm.is_active = 1
      AND (p_query IS NULL OR p_query = '' 
           OR sm.name LIKE CONCAT('%', p_query, '%') 
           OR sm.description LIKE CONCAT('%', p_query, '%')
           OR sm.sku LIKE CONCAT('%', p_query, '%')
           OR EXISTS (SELECT 1 FROM sku_variant WHERE sku_id = sm.sku_id AND sku LIKE CONCAT('%', p_query, '%'))
          )
      AND (p_cat_id IS NULL OR sm.category_id = p_cat_id)
      AND (p_brand_id IS NULL OR sm.brand_id = p_brand_id)
      AND (p_min_price IS NULL OR COALESCE((SELECT MIN(price) FROM sku_variant WHERE sku_id = sm.sku_id), sm.price, 0) >= p_min_price)
      AND (p_max_price IS NULL OR COALESCE((SELECT MIN(price) FROM sku_variant WHERE sku_id = sm.sku_id), sm.price, 0) <= p_max_price);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SetOrderApprovalStatus` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SetOrderApprovalStatus`(
    IN p_order_id INT, 
    IN p_status VARCHAR(50)
)
BEGIN
    UPDATE orders 
    SET approval_status = p_status, 
        updated_at = NOW() 
    WHERE order_id = p_order_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SetOrderGuestEmail` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SetOrderGuestEmail`(
    IN p_order_id INT, 
    IN p_email VARCHAR(255)
)
BEGIN
    UPDATE orders 
    SET guest_email = p_email 
    WHERE order_id = p_order_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SetVariantInventory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SetVariantInventory`(
    IN p_sku_id BIGINT,
    IN p_variant_id BIGINT,
    IN p_store_id INT,
    IN p_quantity INT,
    IN p_threshold INT
)
BEGIN
    INSERT INTO sku_inventory (sku_id, variant_id, store_id, quantity, low_stock_threshold)
    VALUES (p_sku_id, p_variant_id, p_store_id, p_quantity, p_threshold);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SoftDeleteAddress` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SoftDeleteAddress`(IN p_address_id INT, IN p_user_id INT)
BEGIN
    UPDATE user_addresses 
    SET address_type = 'Inactive' 
    WHERE address_id = p_address_id AND user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SubscribeToStock` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SubscribeToStock`(
    IN p_email VARCHAR(255),
    IN p_product_id INT,
    IN p_variant_id BIGINT
)
BEGIN
    -- Only insert if not already waiting for this specific item
    IF NOT EXISTS (
        SELECT 1 FROM stock_notifications 
        WHERE email = p_email 
        AND product_id = p_product_id 
        AND (variant_id = p_variant_id OR (variant_id IS NULL AND p_variant_id IS NULL))
        AND is_notified = 0
    ) THEN
        INSERT INTO stock_notifications (email, product_id, variant_id)
        VALUES (p_email, p_product_id, p_variant_id);
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SyncProductPrimaryImage` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SyncProductPrimaryImage`(IN p_sku_id BIGINT)
BEGIN
    DECLARE v_url VARCHAR(255);
    SELECT media_url INTO v_url FROM sku_media WHERE sku_id = p_sku_id AND variant_id IS NULL ORDER BY is_primary DESC, media_id ASC LIMIT 1;
    IF v_url IS NOT NULL THEN
        UPDATE sku_master SET image_url = v_url WHERE sku_id = p_sku_id;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SyncVolumePricing` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SyncVolumePricing`(IN p_sku_id BIGINT, IN p_pricing_json JSON)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE v_count INT;
    DELETE FROM sku_volume_pricing WHERE sku_id = p_sku_id;
    
    IF p_pricing_json IS NOT NULL THEN
        SET v_count = JSON_LENGTH(p_pricing_json);
        WHILE i < v_count DO
            INSERT INTO sku_volume_pricing (sku_id, min_quantity, price)
            VALUES (p_sku_id, JSON_UNQUOTE(JSON_EXTRACT(p_pricing_json, CONCAT('$[', i, '].min_quantity'))), JSON_UNQUOTE(JSON_EXTRACT(p_pricing_json, CONCAT('$[', i, '].price'))));
            SET i = i + 1;
        END WHILE;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ToggleFavoriteProduct` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `ToggleFavoriteProduct`(IN p_user_id BIGINT, IN p_product_id INT)
BEGIN
    IF EXISTS (SELECT 1 FROM user_favorite_products WHERE user_id = p_user_id AND product_id = p_product_id) THEN
        DELETE FROM user_favorite_products WHERE user_id = p_user_id AND product_id = p_product_id;
        SELECT 0 AS is_favorite;
    ELSE
        INSERT INTO user_favorite_products (user_id, product_id) VALUES (p_user_id, p_product_id);
        SELECT 1 AS is_favorite;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ToggleWorkerStatus` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `ToggleWorkerStatus`(IN p_worker_id BIGINT, IN p_manager_id BIGINT, IN p_is_active INT)
BEGIN
    DECLARE v_store_id INT;
    SELECT store_id INTO v_store_id FROM user_store_mapping WHERE user_id = p_manager_id LIMIT 1;
    
    IF v_store_id IS NOT NULL AND EXISTS(SELECT 1 FROM user_store_mapping WHERE user_id = p_worker_id AND store_id = v_store_id) THEN
        UPDATE users SET is_active = p_is_active WHERE user_id = p_worker_id;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `TrackOrder` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `TrackOrder`(
    IN p_order_number VARCHAR(50)
    -- IN p_email VARCHAR(255)
)
BEGIN
    SELECT o.* FROM orders o
    LEFT JOIN users u ON o.user_id = u.user_id
    WHERE o.order_number = p_order_number ;
   -- AND (o.guest_email = p_email OR u.email = p_email);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateAddress` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateAddress`(
    IN p_address_id INT,
    IN p_user_id INT,
    IN p_address_type VARCHAR(50),
    IN p_line1 VARCHAR(255),
    IN p_line2 VARCHAR(255),
    IN p_city VARCHAR(100),
    IN p_state VARCHAR(100),
    IN p_postal_code VARCHAR(20),
    IN p_country VARCHAR(100)
)
BEGIN
    UPDATE user_addresses
    SET 
        address_type = p_address_type,
        address_line1 = p_line1,
        address_line2 = p_line2,
        city = p_city,
        state = p_state,
        postal_code = p_postal_code,
        country = p_country -- ,
        -- updated_at = NOW()
    WHERE address_id = p_address_id AND user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateAdminProductHeader` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateAdminProductHeader`(
    IN p_sku_id BIGINT, IN p_name VARCHAR(255), IN p_sku VARCHAR(100),
    IN p_price DECIMAL(10,2), IN p_cat_id INT, IN p_brand_id INT,
    IN p_gtin VARCHAR(100), IN p_mpn VARCHAR(100), IN p_desc TEXT, 
    IN p_full_desc TEXT, IN p_admin_comment TEXT,
    IN p_old_price DECIMAL(10,2), IN p_product_cost DECIMAL(10,2),
    IN p_disable_buy TINYINT, IN p_call_price TINYINT, IN p_not_returnable TINYINT,
    IN p_weight DECIMAL(10,2), IN p_length DECIMAL(10,2), IN p_width DECIMAL(10,2), IN p_height DECIMAL(10,2),
    IN p_case_pack INT, IN p_min_cart INT, IN p_max_cart INT,
    IN p_specs TEXT, IN p_warranty TEXT, IN p_mfg_info TEXT,
    IN p_is_active TINYINT
)
BEGIN
    UPDATE sku_master 
    SET name = p_name, sku = p_sku, price = p_price, 
        category_id = p_cat_id, brand_id = p_brand_id, 
        gtin = p_gtin, manufacturer_part_number = p_mpn, 
        description = p_desc, 
        product_definition = p_full_desc, admin_comment = p_admin_comment,
        old_price = p_old_price, product_cost = p_product_cost,
        disable_buy_button = p_disable_buy, call_for_price = p_call_price, not_returnable = p_not_returnable,
        weight = p_weight, length = p_length, width = p_width, height = p_height,
        case_pack_quantity = p_case_pack, minimum_cart_qty = p_min_cart, maximum_cart_qty = p_max_cart,
        specifications = p_specs, warranty_info = p_warranty, manufacturer_info = p_mfg_info,
        is_active = p_is_active, 
        updated_at = CURRENT_TIMESTAMP
    WHERE sku_id = p_sku_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateArea` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateArea`(IN p_area_id INT, IN p_name VARCHAR(255))
BEGIN
    UPDATE areas SET name = p_name WHERE area_id = p_area_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateCategory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateCategory`(
    IN p_category_id INT, 
    IN p_name VARCHAR(255), 
    IN p_description TEXT, 
    IN p_image_url VARCHAR(255)
)
BEGIN
    -- If a new image URL is provided, update everything including the image
    IF p_image_url IS NOT NULL THEN
        UPDATE categories 
        SET name = p_name, description = p_description, image_url = p_image_url 
        WHERE category_id = p_category_id;
    ELSE
        -- If no new image is provided, leave the existing image untouched
        UPDATE categories 
        SET name = p_name, description = p_description 
        WHERE category_id = p_category_id;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateGuestOrderEmail` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateGuestOrderEmail`(IN p_order_id INT, IN p_email VARCHAR(255))
BEGIN
    UPDATE orders 
    SET guest_email = p_email, updated_at = NOW() 
    WHERE order_id = p_order_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateProductMediaPrimary` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateProductMediaPrimary`(IN p_media_id BIGINT, IN p_is_primary TINYINT)
BEGIN
    UPDATE sku_media SET is_primary = p_is_primary WHERE media_id = p_media_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateRegion` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateRegion`(IN p_region_id INT, IN p_name VARCHAR(255))
BEGIN
    UPDATE regions SET name = p_name WHERE region_id = p_region_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateRestaurantFacility` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateRestaurantFacility`(
    IN p_id INT, 
    IN p_name VARCHAR(255), 
    IN p_code VARCHAR(100), 
    IN p_address VARCHAR(255), 
    IN p_city VARCHAR(100), 
    IN p_state VARCHAR(50), 
    IN p_zip VARCHAR(20),
    IN p_tax_rate DECIMAL(5,2)
)
BEGIN
    UPDATE restaurants 
    SET restaurant_name = p_name, 
        restaurant_code = p_code, 
        address = p_address, 
        city = p_city, 
        state = p_state, 
        zip = p_zip,
        tax_rate = p_tax_rate
    WHERE restaurant_id = p_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateStore` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateStore`(
    IN p_store_id INT, IN p_name VARCHAR(255), IN p_code VARCHAR(50),
    IN p_min_order DECIMAL(10,2), IN p_max_order DECIMAL(10,2), IN p_approval DECIMAL(10,2)
)
BEGIN
    UPDATE stores 
    SET name = p_name, 
        store_code = p_code,
        min_order_value = p_min_order,
        max_order_value = p_max_order,
        approval_threshold = p_approval
    WHERE store_id = p_store_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateUserProfile` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateUserProfile`(
    IN p_user_id INT,
    IN p_first_name VARCHAR(100),
    IN p_last_name VARCHAR(100),
    IN p_phone VARCHAR(20)
)
BEGIN
    UPDATE users
    SET first_name = p_first_name,
        last_name = p_last_name,
        phone = p_phone
    WHERE user_id = p_user_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateWarehouseOrderStatus` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateWarehouseOrderStatus`(IN p_order_id INT, IN p_store_id INT, IN p_new_status VARCHAR(50))
BEGIN
    UPDATE orders 
    SET order_status = p_new_status,
        updated_at = CURRENT_TIMESTAMP
    WHERE order_id = p_order_id AND store_id = p_store_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateWarehouseWorker` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateWarehouseWorker`(IN p_worker_id BIGINT, IN p_manager_id BIGINT, IN p_first VARCHAR(100), IN p_last VARCHAR(100), IN p_phone VARCHAR(50))
BEGIN
    DECLARE v_store_id INT;
    SELECT store_id INTO v_store_id FROM user_store_mapping WHERE user_id = p_manager_id LIMIT 1;
    
    IF v_store_id IS NOT NULL AND EXISTS(SELECT 1 FROM user_store_mapping WHERE user_id = p_worker_id AND store_id = v_store_id) THEN
        UPDATE users SET first_name = p_first, last_name = p_last, phone = p_phone WHERE user_id = p_worker_id;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpsertInventoryByCombo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpsertInventoryByCombo`(
    IN p_sku_id BIGINT, IN p_combo_key VARCHAR(255), IN p_store_id INT, 
    IN p_quantity INT, IN p_threshold INT
)
BEGIN
    DECLARE v_variant_id BIGINT;
    IF p_combo_key IS NOT NULL AND p_combo_key != '' THEN
        SELECT variant_id INTO v_variant_id FROM sku_variant WHERE sku_id = p_sku_id AND combination_key = p_combo_key LIMIT 1;
    ELSE
        SET v_variant_id = NULL;
    END IF;

    IF EXISTS (SELECT 1 FROM sku_inventory WHERE sku_id = p_sku_id AND variant_id <=> v_variant_id AND store_id = p_store_id) THEN
        UPDATE sku_inventory SET quantity = p_quantity, low_stock_threshold = p_threshold, updated_at = CURRENT_TIMESTAMP
        WHERE sku_id = p_sku_id AND variant_id <=> v_variant_id AND store_id = p_store_id;
    ELSE
        INSERT INTO sku_inventory (sku_id, variant_id, store_id, quantity, low_stock_threshold)
        VALUES (p_sku_id, v_variant_id, p_store_id, p_quantity, p_threshold);
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpsertProductVariant` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpsertProductVariant`(
    IN p_sku_id BIGINT, IN p_variant_id BIGINT, IN p_sku VARCHAR(100), 
    IN p_price DECIMAL(10,2), IN p_combo_key VARCHAR(255)
)
BEGIN
    IF p_variant_id IS NULL OR p_variant_id = 0 THEN
        INSERT INTO sku_variant (sku_id, sku, price, combination_key)
        VALUES (p_sku_id, p_sku, p_price, p_combo_key);
    ELSE
        UPDATE sku_variant 
        SET sku = p_sku, price = p_price, combination_key = p_combo_key
        WHERE variant_id = p_variant_id AND sku_id = p_sku_id;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-24 22:41:40
