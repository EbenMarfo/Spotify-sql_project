-- Spotify Data Analysis ----

-- Q1 Retrieve the names of all tracks that have more than 1 billion streams.
SELECT * FROM spotify
WHERE stream > 1000000000

-- Q2 List all albums along with their respective artists.
SELECT 
	DISTINCT album,  
	artist
FROM spotify

--Q3 Get the total number of comments for tracks where licensed = TRUE.
SELECT 
	SUM(comments) AS total_comments
FROM spotify
WHERE licensed = TRUE

-- Q4. Find all tracks that belong to the album type single.
SELECT 
	DISTINCT track
FROM spotify
WHERE album_type = 'single'

-- Q5. Count the total number of tracks by each artist
SELECT
 	artist,
	 COUNT(track) AS total_songs
FROM spotify
GROUP BY 1
ORDER BY 2 DESC

--Q6 Calculate the average danceability of tracks in each album.
SELECT 
	album,
	ROUND(AVG(danceability)::NUMERIC, 2) AS avg_dancebility
FROM spotify
GROUP BY 1
ORDER BY 2 DESC

-- Q7 Find the top 5 tracks with the highest energy values.
SELECT 
	track,
	MAX(energy) AS highest_energy
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5
-- Q8 List all tracks along with their views and likes where official_video = TRUE.
SELECT
	DISTINCT track,
	SUM(views) AS total_views,
	SUM(likes) AS total_likes
FROM spotify
WHERE official_video = 'true'
GROUP BY 1
ORDER BY 2 DESC

-- Q9. For each album, calculate the total views of all associated tracks.
SELECT 
	album,
	track,
	SUM(views) total_views
FROM spotify
GROUP BY 1, 2
ORDER BY 3 DESC

--Q10 Retrieve the track names that have been streamed on Spotify more than YouTube.
WITH streaming AS 
(
	SELECT 
		track,
		--most_played_on,
		COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN stream END), 0) AS stream_on_spotify,
		COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN stream END), 0) AS stream_on_youtube
	FROM spotify
	GROUP BY 1
)
SELECT * FROM streaming
WHERE stream_on_spotify > stream_on_youtube
	AND 
		stream_on_youtube  <> 0
	ORDER BY stream_on_spotify DESC

--Q11 Find the top 3 most-viewed tracks for each artist using window functions.
WITH most_viewed_tracks AS 
(
	SELECT 
		artist,
		track,
		SUM(views) total_views,
		DENSE_RANK() OVER (PARTITION BY artist ORDER BY SUM(views) DESC) views_rank
	FROM spotify
	GROUP BY 1, 2
	ORDER BY 1, 3 DESC
)
SELECT * FROM most_viewed_tracks
WHERE views_rank <= 3

--Q12 Write a query to find tracks where the liveness score is above the average.
SELECT AVG(liveness) FROM spotify

SELECT 
	track,
	liveness
FROM spotify
	WHERE liveness > 
		(SELECT AVG(liveness) FROM spotify)
	ORDER BY 2 DESC

--Q13 Use a WITH clause to calculate the difference between the highest and lowest 
     --energy values for tracks in each album
WITH energy_values AS 
(
	SELECT 
		album,
		MAX(energy) AS highest_energy,
		MIN(energy) AS lowest_energy
	FROM spotify
	GROUP BY 1
	ORDER BY 2 DESC
)
SELECT
	album,
	ROUND((highest_energy - lowest_energy)::NUMERIC, 2) AS energy_difference
FROM energy_values
ORDER BY energy_difference DESC