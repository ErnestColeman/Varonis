/****** Script to find all GPOs ******/

SELECT [DirID]

,[DirName]

,[DirLevel]

,[ParentID]

,[CreateDate]

,[entType]

,[AccesspathOrder]

FROM [DirectoryServices].[dbo].[SDT_DirIDs]

where enttype = 511
