<?php
/**
 * Protocol description. This is a very simple protocol for user registration 
 * (or unregistration) and lookup.
 * 
 * For registration, client sends following query string to web-service:
 * 
 * GET ?username=user&identity=peer_id_of_user
 * 
 * Server should respond 200 OK with message body:
 * {"update":"true"}
  * 
 * For unregistration, client sends following request:
 * 
 * GET ?username=user&identity=0 HTTP/1.1
 * 
 * Server response is same as for registration. Registration is refreshed 
 * every 30 minutes.
 * 
 * For user lookup, client sends following request (to avoid caching,
 * request is randomized using time, etc.):
 * 
 * GET ?friends=remote_user HTTP/1.1
 * 
 * If remote user is available, server responds 200 OK with following message body:
 * 
 * {"friend":{
 *     "user":remote_user
 *     "identity":peer_id_of_remote_user
 *   }
 * }
 * 
 * If remote user is not available, server responds with 200 OK with following 
 * message body:
 * {"friend":{
 *     "user":remote_user
 *  }
 * }
 */
 
$dbFile = dirname(__FILE__).'/db/mydatabase.sqlite3';

$db = new SQLite3($dbFile);

$GLOBALS["db"] = $db;

if (!$db) die ("Could not get database.."); 

$outObject = array();

if(!empty($_REQUEST["username"]) && !empty($_REQUEST["identity"])){
	try{
		$user = $_REQUEST["username"];
		$identity = $_REQUEST["identity"];
		$db->exec("insert or replace into registrations values ('$user', '$identity', datetime('now'))");
		$outObject["update"] = true;
	}catch(Exception $e){
		$outObject["update"] = false;
	}
}
function getFriendData($f){
	$friend = array();
	$friend["user"] = $f;
	$query = $GLOBALS["db"]->query("
		select 
			m_username, 
			m_identity 
		from 
			registrations 
		where 
			m_username = '$f' and m_updatetime > datetime('now', '-1 hour')
	");
	if($query){
		while ( ($result = $query->fetchArray())){
			//if(empty($friend["identity"])) $friend["identity"] = array();
			$friend["identity"] = !empty($result["m_identity"]) ? $result["m_identity"] : "";
			if($f != $result["m_username"]){
				//if(empty($friend["registered"])) $friend["registered"] = array();
				$friend["registered"] = $result["m_username"];
			}
		}
	}
	return $friend;
}
if(!empty($_REQUEST["friends"])){
	if(is_array($_REQUEST["friends"])){
		$outObject["friends"] = array();
		foreach($_REQUEST["friends"] as $f){
			$outObject["friends"][] = getFriendData($f, $db);
		}
	}else{
		$outObject["friend"] = getFriendData($_REQUEST["friends"]);
	}
}
$db->close();


header('Content-type: application/json');
echo json_encode($outObject);

?>