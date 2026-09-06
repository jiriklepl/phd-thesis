' In PowerPoint for Windows, press [Alt+F11], choose "Insert" > "Module",
' and paste this entire file. Run ExtractSlideTitlesToMarkdown with [F5].
Option Explicit

Sub ExtractSlideTitlesToMarkdown()
    Dim sld As Slide
    Dim slideTitle As String
    Dim markdownText As String
    Dim filePath As String
    Dim outputStream As Object
    Dim errorMessage As String

    On Error GoTo ExportFailed

    If Presentations.Count = 0 Then
        MsgBox "Open a presentation before exporting slide titles.", vbExclamation, "No Presentation"
        Exit Sub
    End If

    markdownText = "# Slide titles" & vbCrLf & vbCrLf

    ' Include every slide in presentation order, including hidden slides.
    For Each sld In ActivePresentation.Slides
        slideTitle = ""
        If sld.Shapes.HasTitle Then
            slideTitle = sld.Shapes.Title.TextFrame.TextRange.Text
        End If

        slideTitle = SlideTitleMarkdownText(slideTitle)
        If Len(slideTitle) = 0 Then slideTitle = "(Untitled slide)"

        markdownText = markdownText & sld.SlideIndex & ". " & slideTitle & vbCrLf
    Next sld

    filePath = CreateObject("WScript.Shell").SpecialFolders("Desktop") & "\PowerPoint_Slide_Titles.md"

    ' Use UTF-8 to preserve accented characters and symbols.
    ' Late binding avoids requiring an additional VBA reference.
    Set outputStream = CreateObject("ADODB.Stream")
    With outputStream
        .Type = 2 ' adTypeText
        .Charset = "utf-8"
        .Open
        .WriteText markdownText
        .SaveToFile filePath, 2 ' adSaveCreateOverwrite
        .Close
    End With

    MsgBox "Slide titles saved to:" & vbCrLf & filePath, vbInformation, "Extraction Complete"
    Exit Sub

ExportFailed:
    errorMessage = Err.Description
    On Error Resume Next
    If Not outputStream Is Nothing Then outputStream.Close
    MsgBox "Could not export slide titles: " & errorMessage, vbExclamation, "Export Failed"
End Sub

Private Function SlideTitleMarkdownText(ByVal value As String) As String
    Dim specialChar As Variant

    ' Flatten paragraphs and PowerPoint's soft line breaks into one list entry.
    value = Replace(value, vbCrLf, " ")
    value = Replace(value, vbCr, " ")
    value = Replace(value, vbLf, " ")
    value = Replace(value, Chr(11), " ")
    value = Replace(value, vbTab, " ")
    value = Replace(value, ChrW(160), " ")
    Do While InStr(value, "  ") > 0
        value = Replace(value, "  ", " ")
    Loop
    value = Trim$(value)

    ' Keep title text literal when rendered as Markdown (escape backslashes first).
    value = Replace(value, "&", "&amp;")
    For Each specialChar In Array("\", "`", "*", "_", "{", "}", "[", "]", "(", ")", "#", "+", "-", ".", "!", "|", ">", "<", "~")
        value = Replace(value, CStr(specialChar), "\" & CStr(specialChar))
    Next specialChar

    SlideTitleMarkdownText = value
End Function
