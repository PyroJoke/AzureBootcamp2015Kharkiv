WITH tblOrdersByMonth (Product, Extension, [Month], [Year])
AS (
SELECT Product, Price * Quantity as Extension, MONTH(Date) as  [Month], YEAR(Date) as [Year]
FROM dbo.Orders
)
SELECT SUM(Extension) as Amount, [Year], [Month]
FROM tblOrdersByMonth
GROUP BY [Year], [Month]
