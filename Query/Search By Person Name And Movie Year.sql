SELECT
P.Name as ActorName,
B.Category as RoleForMovie,
B.Characters as CharactedPlayed,
T.PrimaryTitle as MovieName,
T.Genres as MovieGenre,
R.Rating as MovieRating
FROM
People as P
INNER JOIN Biography as B
ON B.NameID = P.NameID
INNER JOIN Title as T
ON T.TitleID = B.TitleID
INNER JOIN Rating as R
ON R.TitleID = T.TitleID
WHERE P.Name = 'Arnold Schwarzenegger' AND T.StartYear = 1991