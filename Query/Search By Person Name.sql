SELECT
*
FROM
People as P
INNER JOIN Biography as B
ON B.NameID = P.NameID
INNER JOIN Title as T
ON T.TitleID = B.TitleID
WHERE P.Name = 'Arnold Schwarzenegger'