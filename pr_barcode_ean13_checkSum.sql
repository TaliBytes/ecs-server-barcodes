SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pr_barcode_ean13_checkSum] (
  @value VARCHAR(12)
  )

AS 
  /*Written by Scott Shaffer on 3/24/2022
    Purpose: checksum of content of ean13 barcode based widths
  */
BEGIN
  SET XACT_ABORT ON
  SET NOCOUNT ON

  DECLARE @checkSumWidths VARCHAR(4)
  DECLARE @iteration      INT   --used to track loops
  DECLARE @cursorPosition INT   --used to track current digit being read from value
  DECLARE @subValue       INT   --current digit value
  DECLARE @evenSum        INT   --total sum of even digits
  DECLARE @oddSum         INT   --total sum of odd digits multipled by 3
  DECLARE @finalSum       INT   --sum of odd and even digits

  SET @iteration = 0
  SET @cursorPosition = 1
  SET @oddSum = 0
  SET @evenSum = 0

  WHILE 5 >= @iteration         --add up odd digit positions
    BEGIN
      SELECT @subValue = SUBSTRING(@value,@cursorPosition,1)
      SELECT @subValue = @subValue * 1
      
      SET @oddSum = @oddSum + @subValue
      SET @iteration = @iteration + 1
      SET @cursorPosition = @cursorPosition + 2
    END

  IF @iteration = 6
    BEGIN
      SET @cursorPosition = 2
    END

  WHILE 11 >= @iteration
    BEGIN
      SELECT @subValue = SUBSTRING(@value,@cursorPosition,1)
      SELECT @subValue = @subValue * 3

      SELECT @evenSum = @evenSum + @subValue
      SET @iteration = @iteration + 1
      SET @cursorPosition = @cursorPosition + 2
    END

  SET @finalSum = @evenSum + @oddSum
  SET @finalSum = ((FLOOR(@finalSum / 10) + 1) * 10) - @finalSum

  IF @finalSum = 10 BEGIN SELECT @finalSum = 0 END
  SELECT @checkSumWidths = widthsLR FROM barcodeEAN13_data WHERE outputValue = @finalSum
  SELECT @checkSumWidths, @finalSum as checkSumValue
END

GO
