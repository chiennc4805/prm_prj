package com.myfs.backend.controller;

import com.myfs.backend.service.TeacherExcelService;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/admin/teachers")
public class TeacherExcelController {
    private final TeacherExcelService excel;
    public TeacherExcelController(TeacherExcelService excel) { this.excel = excel; }

    @GetMapping("/import-template")
    public ResponseEntity<byte[]> template() {
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=mau-nhap-giao-vien.xlsx")
                .contentType(MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                .body(excel.template());
    }

    @PostMapping(value = "/import-preview", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public TeacherExcelService.PreviewResult preview(@RequestPart("file") MultipartFile file) { return excel.preview(file); }

    @PostMapping("/import")
    public TeacherExcelService.ImportResult importTeachers(@RequestBody TeacherExcelService.ImportRequest request) { return excel.importTeachers(request); }
}
