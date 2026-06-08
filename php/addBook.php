<?php

error_reporting(E_ALL);
ini_set('display_errors', 1);

$db = "projet";
$dbuser = "root"; 
$dbpassword = ""; 
$dbhost = "localhost";

$link = mysqli_connect($dbhost, $dbuser, $dbpassword, $db);

$data = json_decode(file_get_contents("php://input"), true);

if (!$data) {
    die(json_encode(["success" => false, "message" => "No data received"]));
}

$title = $data['title'];
$author = $data['author'];
$genre = $data['genre'];
$price = $data['price'];
$image = $data['image'];
$year = $data['year'];
$description = $data['description'];
$rating = $data['rating'];
$number_of_likes = $data['number_of_likes'];
$quantity_in_stock = $data['quantity_in_stock'];

$query = "INSERT INTO books (title, author, genre, price, image, year, description, rating,  quantity_in_stock, number_of_likes)
          VALUES ('$title', '$author', '$genre', '$price', '$image', '$year', '$description', '$rating', '$quantity_in_stock','$number_of_likes')";

$result = mysqli_query($link, $query);

if ($result) {
    echo json_encode(["success" => true, "message" => "Book inserted successfully"]);
} else {
    echo json_encode(["success" => false, "message" => "Insert failed: " . mysqli_error($link)]);
}
?>
