/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping database structure for cfartgallery
CREATE DATABASE IF NOT EXISTS `cfartgallery` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `cfartgallery`;


-- Dumping structure for table cfartgallery.art
DROP TABLE IF EXISTS `art`;
CREATE TABLE IF NOT EXISTS `art` (
  `ARTID` int(11) NOT NULL AUTO_INCREMENT,
  `ARTISTID` int(11) DEFAULT NULL,
  `ARTNAME` varchar(50) DEFAULT NULL,
  `DESCRIPTION` longtext,
  `PRICE` decimal(19,0) DEFAULT NULL,
  `LARGEIMAGE` varchar(30) DEFAULT NULL,
  `MEDIAID` int(11) DEFAULT NULL,
  `ISSOLD` smallint(6) DEFAULT NULL,
  UNIQUE KEY `SQL070515103201660` (`ARTID`)
) ENGINE=MyISAM AUTO_INCREMENT=56 DEFAULT CHARSET=utf8;

-- Dumping data for table cfartgallery.art: 55 rows
/*!40000 ALTER TABLE `art` DISABLE KEYS */;
INSERT INTO `art` (`ARTID`, `ARTISTID`, `ARTNAME`, `DESCRIPTION`, `PRICE`, `LARGEIMAGE`, `MEDIAID`, `ISSOLD`) VALUES
	(1, 1, 'charles1', 'Pastels/Charcoal', 10000, 'aiden01.jpg', 1, 1),
	(2, 1, 'Michael', 'Pastels/Charcoal', 13900, 'aiden02.jpg', 1, 0),
	(3, 1, 'Freddy', 'Pastels/Charcoal', 12500, 'aiden03.jpg', 1, 1),
	(4, 1, 'Paulo', 'Pastels/Charcoal', 11100, 'aiden04.jpg', 1, 1),
	(5, 1, 'Mary', 'Pastels/Charcoal', 13550, 'aiden05.jpg', 1, 1),
	(6, 3, 'Space', 'Mixed Media', 9800, 'elecia01.jpg', 2, 1),
	(7, 3, 'Leaning House', 'Mixed Media', 7800, 'elecia02.jpg', 2, 1),
	(8, 3, 'Dude', 'Mixed Media', 5600, 'elecia03.jpg', 2, 1),
	(9, 3, 'Hang Ten', 'Mixed Media', 8900, 'elecia04.jpg', 2, 0),
	(10, 3, 'Life is a Horse', 'Mixed Media', 10500, 'elecia05.jpg', 2, 0),
	(11, 2, '1958', 'Charcoal ', 75000, 'austin01.jpg', 1, 1),
	(12, 2, 'Toxic', 'Charcoal', 22000, 'austin02.jpg', 1, 1),
	(13, 2, 'Prize Fight', 'Charcoal ', 25000, 'austin03.jpg', 1, 1),
	(14, 2, 'You Don\'t Know Me', 'Charcoal', 42700, 'austin04.jpg', 1, 0),
	(15, 2, 'Do it', 'Charcoal', 30000, 'austin05.jpg', 1, 1),
	(16, 4, 'Bowl of Flowers', 'Acrylic', 11800, 'jeff01.jpg', 1, 1),
	(17, 4, '60 Vibe', 'Acrylic ', 25000, 'jeff02.jpg', 1, 0),
	(18, 4, 'Naked', 'Acrylic', 30000, 'jeff03.jpg', 1, 1),
	(19, 4, 'Sky', 'Acrylic', 15000, 'jeff04.jpg', 1, 1),
	(20, 4, 'Slices of Life', 'Acrylic', 20000, 'jeff05.jpg', 1, 0),
	(21, 6, 'Morning Forest', 'Oil', 250000, 'maxwell01.jpg', 1, 0),
	(22, 6, 'Things', 'Oil', 300000, 'maxwell02.jpg', 1, 1),
	(23, 6, 'The Lake', 'Oil', 150000, 'maxwell03.jpg', 1, 0),
	(24, 6, 'Morph', 'Oil', 10500, 'maxwell04.jpg', 1, 0),
	(25, 6, 'Ideas', 'Oil', 250000, 'maxwell05.jpg', 1, 1),
	(26, 5, 'Christmas', 'Pastels', 54000, 'lori01.jpg', 1, 1),
	(27, 5, 'Happiness', 'Pastels', 65000, 'lori02.jpg', 1, 1),
	(28, 5, 'Closed', 'Pastels', 40000, 'lori03.jpg', 1, 0),
	(29, 5, 'Enchanted Tree', 'Pastels', 350000, 'lori04.jpg', 1, 0),
	(30, 5, 'Melon', 'Pastels', 200000, 'lori05.jpg', 1, 0),
	(31, 7, 'Music', 'Oils', 72000, 'paul01.jpg', 1, 0),
	(32, 7, 'Empty', 'Oils', 35000, 'paul02.jpg', 1, 1),
	(33, 7, 'My Venus', 'Oils', 58000, 'paul03.jpg', 1, 0),
	(34, 7, 'Man in Jeans', 'Oils', 100000, 'paul04.jpg', 1, 0),
	(35, 7, 'Man on Stool', 'Oils', 90000, 'paul05.jpg', 1, 1),
	(36, 8, 'Mystery', 'Pastels', 250000, 'raquel01.jpg', 1, 0),
	(37, 8, 'Paradise', 'Pastels', 300000, 'raquel02.jpg', 1, 0),
	(38, 8, 'Mountains', 'Pastels', 150000, 'raquel03.jpg', 1, 1),
	(39, 8, 'Mom', 'Pastels', 85000, 'raquel04.jpg', 1, 0),
	(40, 8, 'Beauty', 'Pastels', 100000, 'raquel05.jpg', 1, 0),
	(41, 9, 'Cowboy', 'Watercolor', 40000, 'viata01.jpg', 1, 0),
	(42, 9, 'Pretty Life', 'Watercolor', 35000, 'viata02.jpg', 1, 0),
	(43, 9, 'Singer', 'Watercolor', 56500, 'viata03.jpg', 1, 0),
	(44, 9, 'Windy', 'Watercolor', 36000, 'viata04.jpg', 1, 1),
	(45, 9, 'Yellow to Me', 'Watercolor', 20000, 'viata05.jpg', 1, 1),
	(46, 19, 'Garden', 'Photograph', 35000, 'anthony01.jpg', 6, 1),
	(47, 19, 'Flower', 'Photograph', 20000, 'anthony02.jpg', 6, 0),
	(48, 19, 'White Flowers', 'Photograph', 45000, 'anthony03.jpg', 6, 1),
	(49, 19, 'Ground Cover', 'Photograph', 3456764, 'anthony04.jpg', 6, 0),
	(50, 19, 'Blue Moon', 'Photograph', 30000, 'anthony05.jpg', 6, 1),
	(51, 20, 'Cow', 'Painting', 23000, 'ellery01.jpg', 0, 0),
	(52, 20, 'Picasso', 'Painting', 14000, 'ellery02.jpg', 0, 0),
	(53, 21, 'Miro', 'Painting', 10000, 'emma01.jpg', 0, 0),
	(54, 22, 'Dino', 'Painting', 12000, 'taylor01.jpg', 0, 0),
	(55, 4, 'sda', NULL, 10, '7', NULL, NULL);
/*!40000 ALTER TABLE `art` ENABLE KEYS */;


-- Dumping structure for table cfartgallery.artists
DROP TABLE IF EXISTS `artists`;
CREATE TABLE IF NOT EXISTS `artists` (
  `ARTISTID` int(11) NOT NULL AUTO_INCREMENT,
  `FIRSTNAME` varchar(20) DEFAULT NULL,
  `LASTNAME` varchar(20) DEFAULT NULL,
  `ADDRESS` varchar(50) DEFAULT NULL,
  `CITY` varchar(20) DEFAULT NULL,
  `STATE` varchar(2) DEFAULT NULL,
  `POSTALCODE` varchar(10) DEFAULT NULL,
  `EMAIL` varchar(50) DEFAULT NULL,
  `PHONE` varchar(20) DEFAULT NULL,
  `FAX` varchar(12) DEFAULT NULL,
  `THEPASSWORD` varchar(8) DEFAULT NULL,
  UNIQUE KEY `SQL070515103201950` (`ARTISTID`)
) ENGINE=MyISAM AUTO_INCREMENT=16 DEFAULT CHARSET=utf8;

-- Dumping data for table cfartgallery.artists: 15 rows
/*!40000 ALTER TABLE `artists` DISABLE KEYS */;
INSERT INTO `artists` (`ARTISTID`, `FIRSTNAME`, `LASTNAME`, `ADDRESS`, `CITY`, `STATE`, `POSTALCODE`, `EMAIL`, `PHONE`, `FAX`, `THEPASSWORD`) VALUES
	(1, 'Aiden', 'Donolan', '352 Corporate Ave.', 'Denver', 'CO', '80206-4526', 'aiden.donolan@donolan.com', '555-751-8464', '555-751-8463', 'peapod'),
	(2, 'Austin', 'Weber', '25463 Main Street, Suite C', 'Berkeley', 'CA', '94707-4513', 'austin@life.com', '555-513-4318', '510-513-4888', 'nopolyes'),
	(3, 'Elicia', 'Kim', '2523 National Blvd', 'Los Angeles', 'CA', '90064-5134', 'eleciakim@newmedia.com', '555-846-4613', '', 'longtail'),
	(4, 'Jeff', 'Baclawski', '903 Boardwalk Ave', 'Hollywood', 'FL', '33021-8894', 'user@demodata.com', '239-213-4561', '239-213-7465', 'demo'),
	(5, 'Lori', 'Johnson', '6462 Cowtown Rd', 'Pierre', 'SD', '57501-7782', 'lb@bovinas.com', '605-776-8461', '605-776-8462', 'nowhere'),
	(6, 'Maxwell', 'Wilson', '72500 MLK Blvd', 'Tulsa', 'OK', '74116-4613', 'max@mypaintings.com', '918-347-4513', '918-456-1315', 'eyeball'),
	(7, 'Paul', 'Trani', '3320 Fashion Dr', 'New York', 'NY', '10017-1231', 'paul.trani@trani.com', '212-630-5345', NULL, 'ouchy'),
	(8, 'Raquel', 'Young', '1120 Presidential Ave', 'Atlanta', 'GA', '39901-4813', 'raquel@soulpaints.com', '770-397-9486', '770-391-8435', 'cmyk'),
	(9, 'Viata', 'Trenton', '4563 42nd St', 'New York', 'NY', '10012-4562', 'trenton.v@trenton.com', '212-456-8468', '212-468-8765', 'pillow'),
	(10, 'Diane', 'Demo', '123 Demo Lane', 'Denver', 'CO', '55555', 'diane@demo.com', '555-555-5555', '', 'demo'),
	(11, 'Anthony', 'Kunovic', '111 94th Ave', 'Aspen', 'CO', '90809', 'aj@ajgalleries.com', '970-555-1373', NULL, 'overlord'),
	(12, 'Ellery', 'Buntel', '23 Elm St', 'Washington', 'DC', '77893', 'ellery.buntel@myart.com', '637-902-7200', '637-300-2888', 'crayon'),
	(13, 'Emma', 'Buntel', '789 Main St', 'Washington', 'DC', '77834', 'emma.buntel@myart.com', '637-930-2999', NULL, 'bluebird'),
	(14, 'Taylor Webb', 'Frazier', '58 Plaza Ct', 'Santa Fe', 'NM', '34453', 'taylor.webb@myart.com', '444-333-9876', NULL, 'icecream'),
	(15, 'Mike', 'Nimer', 'qwed qdsa', 'asd da', 'ca', '01321', 'me@m.com', NULL, NULL, 'admin');
/*!40000 ALTER TABLE `artists` ENABLE KEYS */;


-- Dumping structure for table cfartgallery.galleryadmin
DROP TABLE IF EXISTS `galleryadmin`;
CREATE TABLE IF NOT EXISTS `galleryadmin` (
  `GALLERYADMINID` int(11) NOT NULL AUTO_INCREMENT,
  `FIRSTNAME` varchar(20) DEFAULT NULL,
  `LASTNAME` varchar(20) DEFAULT NULL,
  `EMAIL` varchar(50) DEFAULT NULL,
  `ADMINPASSWORD` varchar(8) DEFAULT NULL,
  UNIQUE KEY `SQL070515103202180` (`GALLERYADMINID`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- Dumping data for table cfartgallery.galleryadmin: 3 rows
/*!40000 ALTER TABLE `galleryadmin` DISABLE KEYS */;
INSERT INTO `galleryadmin` (`GALLERYADMINID`, `FIRSTNAME`, `LASTNAME`, `EMAIL`, `ADMINPASSWORD`) VALUES
	(1, 'Suzanne', 'White', 'swhite@fashiongalleria.com', 'bludress'),
	(2, 'Mike', 'Green', 'mgreen@fashiongalleria.com', 'organza'),
	(3, 'Darrell', 'Demo', 'admin@demodata.com', 'demo');
/*!40000 ALTER TABLE `galleryadmin` ENABLE KEYS */;


-- Dumping structure for table cfartgallery.media
DROP TABLE IF EXISTS `media`;
CREATE TABLE IF NOT EXISTS `media` (
  `MEDIAID` int(11) NOT NULL AUTO_INCREMENT,
  `MEDIATYPE` varchar(50) DEFAULT NULL,
  UNIQUE KEY `SQL070515103202370` (`MEDIAID`)
) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;

-- Dumping data for table cfartgallery.media: 8 rows
/*!40000 ALTER TABLE `media` DISABLE KEYS */;
INSERT INTO `media` (`MEDIAID`, `MEDIATYPE`) VALUES
	(1, 'Painting'),
	(2, 'Sculpure'),
	(3, 'Pottery'),
	(4, 'Jewelry'),
	(5, 'Tapestry'),
	(6, 'Photography'),
	(7, 'Functional'),
	(8, 'Wearable');
/*!40000 ALTER TABLE `media` ENABLE KEYS */;


-- Dumping structure for table cfartgallery.orderitems
DROP TABLE IF EXISTS `orderitems`;
CREATE TABLE IF NOT EXISTS `orderitems` (
  `ORDERITEMID` int(11) NOT NULL AUTO_INCREMENT,
  `ORDERID` int(11) DEFAULT NULL,
  `ARTID` int(11) DEFAULT NULL,
  `PRICE` decimal(19,0) DEFAULT NULL,
  UNIQUE KEY `SQL070515103202650` (`ORDERITEMID`)
) ENGINE=MyISAM AUTO_INCREMENT=25 DEFAULT CHARSET=utf8;

-- Dumping data for table cfartgallery.orderitems: 24 rows
/*!40000 ALTER TABLE `orderitems` DISABLE KEYS */;
INSERT INTO `orderitems` (`ORDERITEMID`, `ORDERID`, `ARTID`, `PRICE`) VALUES
	(1, 1, 1, 10000),
	(2, 2, 3, 12400),
	(3, 2, 5, 13550),
	(4, 3, 6, 9800),
	(5, 4, 7, 7800),
	(6, 5, 8, 5600),
	(7, 6, 11, 75000),
	(8, 7, 12, 22000),
	(9, 8, 15, 30000),
	(10, 9, 16, 11800),
	(11, 10, 18, 30000),
	(12, 11, 44, 36000),
	(13, 12, 45, 20000),
	(14, 13, 38, 150000),
	(15, 14, 35, 90000),
	(16, 15, 32, 35000),
	(17, 16, 19, 15000),
	(18, 17, 25, 250000),
	(19, 18, 4, 11100),
	(20, 19, 22, 300000),
	(21, 20, 27, 65000),
	(22, 21, 46, 35000),
	(23, 22, 48, 45000),
	(24, 23, 50, 30000);
/*!40000 ALTER TABLE `orderitems` ENABLE KEYS */;


-- Dumping structure for table cfartgallery.orders
DROP TABLE IF EXISTS `orders`;
CREATE TABLE IF NOT EXISTS `orders` (
  `ORDERID` int(11) NOT NULL AUTO_INCREMENT,
  `TAX` decimal(19,0) DEFAULT NULL,
  `TOTAL` decimal(19,0) DEFAULT NULL,
  `ORDERDATE` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `ORDERSTATUSID` int(11) DEFAULT NULL,
  `CUSTOMERFIRSTNAME` varchar(50) DEFAULT NULL,
  `CUSTOMERLASTNAME` varchar(50) DEFAULT NULL,
  `ADDRESS` varchar(50) DEFAULT NULL,
  `CITY` varchar(50) DEFAULT NULL,
  `STATE` varchar(50) DEFAULT NULL,
  `POSTALCODE` varchar(50) DEFAULT NULL,
  `PHONE` varchar(50) DEFAULT NULL,
  UNIQUE KEY `SQL070515103202850` (`ORDERID`)
) ENGINE=MyISAM AUTO_INCREMENT=24 DEFAULT CHARSET=utf8;

-- Dumping data for table cfartgallery.orders: 23 rows
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` (`ORDERID`, `TAX`, `TOTAL`, `ORDERDATE`, `ORDERSTATUSID`, `CUSTOMERFIRSTNAME`, `CUSTOMERLASTNAME`, `ADDRESS`, `CITY`, `STATE`, `POSTALCODE`, `PHONE`) VALUES
	(1, 400, 10400, '2003-06-10 00:00:00', 1, 'Bob', 'Green', '12 Gover St', 'Oakland', 'CA', '45794', NULL),
	(2, 1038, 26988, '2002-07-02 00:00:00', 5, 'Sue', 'White', '123 4th St', 'Greeley', 'CO', '55555', NULL),
	(3, 392, 10192, '2001-06-05 00:00:00', 5, 'Tiffany', 'Rose', '11267 Green St', 'Seattle', 'WA', '34567', NULL),
	(4, 312, 8112, '2003-06-18 00:00:00', 5, 'Frank', 'Smith', '78 45th Ave', 'Las Vegas', 'NV', '68689', NULL),
	(5, 224, 5824, '2001-05-22 00:00:00', 5, 'Anthony', 'Shumacher', '988 Brownlee Way', 'Denver', 'CO', '30604', NULL),
	(6, 3000, 78000, '2004-04-01 00:00:00', 1, 'Jerry', 'Day', '689 Dell Ave', 'Santa Fe', 'NM', '39087', NULL),
	(7, 880, 22880, '2001-08-28 00:00:00', 5, 'Dave', 'Cardinal', '234 Phoenix Way', 'Phoenix', 'AZ', '33399', NULL),
	(8, 1200, 31200, '2002-12-25 00:00:00', 5, 'Mary', 'Carter', '944 Eaton Way', 'Colorado Springs', 'CO', '90004', NULL),
	(9, 472, 12272, '2001-01-13 00:00:00', 5, 'Cheryl', 'Masters', '6 23rd', 'Ogden', 'UT', '56555', NULL),
	(10, 1200, 31200, '2004-02-05 00:00:00', 2, 'Louahn', 'Lloyd', 'Scottsdale Circle', 'Scottsdale', 'AZ', '45677', NULL),
	(11, 1440, 37440, '2004-09-19 00:00:00', 2, 'Nancy', 'Smithers', '4 Palm Dr', 'Houston', 'TX', '34500', NULL),
	(12, 800, 20800, '2003-05-25 00:00:00', 5, 'Bob', 'Franks', '456 W. 6th', 'Deadwood', 'OK', '98999', NULL),
	(13, 6000, 156000, '2003-07-09 00:00:00', 5, 'Michael', 'Harvey', '23 Land Park', 'Cheyenne', 'WY', '80906', NULL),
	(14, 3600, 93600, '2003-12-11 00:00:00', 5, 'Jane', 'Downs', '234 54th St', 'New York', 'NY', '20405', NULL),
	(15, 1400, 36400, '2004-01-30 00:00:00', 2, 'Kerry', 'Kerns', '34 Lincoln Way', 'Boston', 'MA', '30445', NULL),
	(16, 600, 15600, '2004-03-16 00:00:00', 2, 'Emily', 'Michaels', '8999 1st Ave', 'Anytown', 'AK', '90806', NULL),
	(17, 10000, 260000, '2004-05-25 00:00:00', 2, 'Joe', 'Anthony', '1555 Quail St', 'Denver', 'CO', '80215', NULL),
	(18, 444, 11544, '2004-06-13 00:00:00', 2, 'Pauette', 'Crow', '45 54th Drive', 'Dallas', 'TX', '34120', NULL),
	(19, 12000, 312000, '2004-07-25 00:00:00', 2, 'David', 'Kissler', '5673 Summit Ave', 'Los Angeles', 'CA', '80910', NULL),
	(20, 2600, 67600, '2004-08-12 00:00:00', 2, 'Matt', 'Armstrong', '76 120th', 'Kansas City', 'KS', '44980', NULL),
	(21, 1400, 36400, '2003-03-16 00:00:00', 5, 'Joe', 'Kunovic', '3987 Frontage Road', 'Boston', 'MA', '39500', NULL),
	(22, 1800, 46800, '2004-03-16 00:00:00', 3, 'Annette', 'Kunovic', '4589 Main St', 'New York', 'NY', '89993', NULL),
	(23, 1200, 31200, '2004-06-19 00:00:00', 1, 'Allen', 'Rice', '34 First Lane', 'Los Angeles', 'CA', '67839', NULL);
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;


-- Dumping structure for table cfartgallery.orderstatus
DROP TABLE IF EXISTS `orderstatus`;
CREATE TABLE IF NOT EXISTS `orderstatus` (
  `ORDERSTATUSID` int(11) NOT NULL AUTO_INCREMENT,
  `STATUS` varchar(15) DEFAULT NULL,
  UNIQUE KEY `SQL070515103203070` (`ORDERSTATUSID`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

-- Dumping data for table cfartgallery.orderstatus: 5 rows
/*!40000 ALTER TABLE `orderstatus` DISABLE KEYS */;
INSERT INTO `orderstatus` (`ORDERSTATUSID`, `STATUS`) VALUES
	(1, 'pending'),
	(2, 'complete'),
	(3, 'shipped'),
	(4, 'billed'),
	(5, 'paid');
/*!40000 ALTER TABLE `orderstatus` ENABLE KEYS */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
