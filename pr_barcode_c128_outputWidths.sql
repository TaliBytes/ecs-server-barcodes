SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pr_barcode_c128_outputWidths] (
  @symbology varchar(5),
  @value VARCHAR(40),
  @widths VARCHAR(240) NULL OUTPUT
  )

AS 
  /*Written by Scott Shaffer on 3/24/2022
    Purpose: convert input value for a barcode to necessary barcode widths for c128 standards
  */
BEGIN
  SET XACT_ABORT ON
  SET NOCOUNT ON
  
  DECLARE @singleWidth VARCHAR(6)    --selects width of one char at a time
  DECLARE @substring VARCHAR(2)      --selects one char at a time to convert to its width value
  DECLARE @stringLength INT          --stores length of the input value string
  DECLARE @iteration INT             --selects the current i iteration of a loop
  SELECT @iteration = 0
  

  IF @symbology = 'c128a' OR @symbology = 'c128b'
    BEGIN
      SELECT @stringLength = LEN(@value)                             --selects length of the string
      WHILE @iteration <= @stringLength                              --emulates for loop
        BEGIN
          SELECT @substring = SUBSTRING(@value, @iteration, 1)       --selects substring to be the i character from value based on the i iteration of the loop
                                 
          IF @symbology = 'c128a' BEGIN SELECT @singleWidth = widths FROM barcodeC128_data WHERE outputA = @substring END       --selects width value for associated character in the loop.
          IF @symbology = 'c128b' BEGIN SELECT @singleWidth = widths FROM barcodeC128_data WHERE outputB = @substring END
          SELECT @widths = CONCAT(@widths, @singleWidth)                                                                        --selects widths, and concats new value to the existing value

          SET @iteration = @iteration + 1                            --increments iteration up by 1. Needed to emulate 4 loop and select the character in the string 
        END  --END LOOP
    END  --END c128a and c128b


  IF @symbology = 'c128c' OR @symbology = 'c128'
    BEGIN
      DECLARE @cursorPosition INT                     --position where chunk of value should be read from
      SELECT @stringLength = LEN(@value)              --select length of string for while loop
      WHILE @iteration < @stringLength               --runs i times based on iteration and string length
        BEGIN
          SELECT @cursorPosition = @iteration + 1                                         --cursor position is set to same as iteration but incremented by 1
          SELECT @substring = SUBSTRING(@value, @cursorPosition, 2)                       --substring equals 2 characters starting at cursorPosition from value
          SELECT @singleWidth = widths FROM barcodeC128_data WHERE outputC = @substring   --singleWidth for the substring value is retrieved from the database
          SELECT @widths = CONCAT(@widths, @singleWidth)                                  --widths concats singleWidth onto the end of itself

          SET @iteration = @iteration + 2                                                 --iteration is incremented by two because c128c is read 2 characters at a time
        END  --end of loop
    END  --end of c128c


  SELECT @widths
END

GO
