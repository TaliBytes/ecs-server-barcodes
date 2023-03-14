SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pr_barcode_c128_checkSum] (
  @symbology varchar(5),
  @widths VARCHAR(240)
  )

AS 
  /*Written by Scott Shaffer on 3/24/2022
    Purpose: checksum of content of c128 barcode based on sub-symbology and widths
  */
BEGIN
  SET XACT_ABORT ON
  SET NOCOUNT ON
  
  DECLARE @checkSumWidths VARCHAR(6)                --width values for the checksum, final output
  DECLARE @iteration INT SET @iteration = 0         --iteration for while Loop
  DECLARE @charPosition INT SET @charPosition = 1   --charPosition for each loop
  DECLARE @symbologyValue INT                       --symbologyValue number, based on symbology and sub-symbology (start code value)
  DECLARE @checkSumValue INT                        --valueCode for the checkSum before it is converted to widths
  DECLARE @checkSubValue INT                        --valueCode for part of the checkSum before it is operated on
  DECLARE @stringLength INT                         --total length of the widths
  DECLARE @subWidth VARCHAR(6)                      --selects 6 char at a time to convert to its normal value
  DECLARE @singleValue VARCHAR(3)                   --select the value from each subWidth

    /*  Select the correct symbologyValue based on the symbology  */
    IF @symbology = 'c128a' BEGIN SELECT @symbologyValue = 103 END
    IF @symbology = 'c128b' BEGIN SELECT @symbologyValue = 104 END
    IF @symbology = 'c128c' OR @symbology = 'c128' BEGIN SELECT @symbologyValue = 105 END



    /*  add start value and then each (iteration position * singleValue) together  */
    SET @checkSumValue = @symbologyValue    --step 1, add the symbologyValue
    
    DECLARE @cursorPosition INT                     --position where chunk of value should be read from
    SELECT @stringLength = LEN(@widths)             --select length of string for while loop
    WHILE @iteration < @stringLength                --runs i times based on iteration and string length
      BEGIN
        SELECT @cursorPosition = @iteration + 1                                         --cursor position is set to same as iteration but incremented by 1
        SELECT @subWidth = SUBSTRING(@widths, @cursorPosition, 6)                       --substring equals 6 characters starting at cursorPosition from value
        SELECT @singleValue = value FROM barcodeC128_data WHERE widths = @subWidth      --select subValue for the singleWidth

        SET @checkSubValue = (@charPosition) * @singleValue                               --subValue for checkSum is calculated
        SET @checkSumValue = @checkSumValue + @checkSubValue                              --subValue for checkSum is added to checkSum
        SET @iteration = @iteration + 6                                                   --iteration is incremented by two because widths is read 6 characters at a time
        SET @charPosition = @charPosition + 1
      END  --end of loop




    SET @checkSumValue = @checkSumValue % 103                                             --Modulus (get remainder only) from division of checkSumValue by 103
    SELECT @checkSumWidths = widths FROM barcodeC128_data WHERE value = @checkSumValue    --widths value for checkSum

  SELECT @checkSumWidths
END

GO
