package com.myfs.backend.service;

import com.myfs.backend.dao.AppUserDao;
import com.myfs.backend.model.AppUser;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.ByteArrayOutputStream;
import java.util.*;
import java.util.regex.Pattern;

@Service
public class TeacherExcelService {
    private static final int MAX_ROWS = 500;
    private static final Pattern EMAIL = Pattern.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");
    private final AppUserDao users;

    public TeacherExcelService(AppUserDao users) { this.users = users; }

    public record TeacherRow(Integer rowNumber, String fullName, String phone, String email, boolean valid, List<String> errors) {}
    public record PreviewResult(int totalRows, int validRows, int invalidRows, List<TeacherRow> rows) {}
    public record ImportItem(String fullName, String phone, String email) {}
    public record ImportRequest(List<ImportItem> teachers) {}
    public record ImportResult(int successCount, int failedCount, String message, List<String> errors) {}

    public byte[] template() {
        try (Workbook workbook = new XSSFWorkbook(); ByteArrayOutputStream output = new ByteArrayOutputStream()) {
            Sheet sheet = workbook.createSheet("GiaoVien");
            Row header = sheet.createRow(0);
            String[] labels = {"Họ và tên", "Số điện thoại", "Email"};
            CellStyle headerStyle = workbook.createCellStyle();
            Font font = workbook.createFont(); font.setBold(true); headerStyle.setFont(font);
            for (int i = 0; i < labels.length; i++) { Cell cell = header.createCell(i); cell.setCellValue(labels[i]); cell.setCellStyle(headerStyle); }
            Row sample = sheet.createRow(1);
            sample.createCell(0).setCellValue("Nguyễn Văn An");
            sample.createCell(1).setCellValue("0901234567");
            sample.createCell(2).setCellValue("an@example.com");
            sheet.setColumnWidth(0, 28 * 256); sheet.setColumnWidth(1, 20 * 256); sheet.setColumnWidth(2, 30 * 256);
            workbook.write(output);
            return output.toByteArray();
        } catch (Exception error) { throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Không thể tạo file mẫu"); }
    }

    public PreviewResult preview(MultipartFile file) {
        validateFile(file);
        List<TeacherRow> result = new ArrayList<>();
        Set<String> phonesInFile = new HashSet<>();
        Set<String> emailsInFile = new HashSet<>();
        try (Workbook workbook = WorkbookFactory.create(file.getInputStream())) {
            Sheet sheet = workbook.getSheetAt(0);
            if (sheet.getLastRowNum() > MAX_ROWS) throw bad("File chỉ được chứa tối đa " + MAX_ROWS + " giáo viên");
            DataFormatter formatter = new DataFormatter();
            for (int index = 1; index <= sheet.getLastRowNum(); index++) {
                Row row = sheet.getRow(index);
                String name = cell(row, 0, formatter), phone = cell(row, 1, formatter), email = cell(row, 2, formatter);
                if (name.isBlank() && phone.isBlank() && email.isBlank()) continue;
                List<String> errors = validate(name, phone, email, phonesInFile, emailsInFile);
                result.add(new TeacherRow(index + 1, name, phone, email, errors.isEmpty(), errors));
            }
        } catch (ResponseStatusException error) { throw error; }
        catch (Exception error) { throw bad("Không thể đọc file Excel. Hãy sử dụng file .xlsx đúng định dạng"); }
        long valid = result.stream().filter(TeacherRow::valid).count();
        return new PreviewResult(result.size(), (int) valid, result.size() - (int) valid, result);
    }

    @Transactional
    public ImportResult importTeachers(ImportRequest request) {
        if (request == null || request.teachers() == null || request.teachers().isEmpty()) throw bad("Không có giáo viên hợp lệ để nhập");
        if (request.teachers().size() > MAX_ROWS) throw bad("Chỉ được nhập tối đa " + MAX_ROWS + " giáo viên");
        Set<String> phones = new HashSet<>();
        Set<String> emails = new HashSet<>();
        List<String> errors = new ArrayList<>();
        for (int i = 0; i < request.teachers().size(); i++) {
            ImportItem item = request.teachers().get(i);
            List<String> rowErrors = validate(clean(item.fullName()), clean(item.phone()), clean(item.email()), phones, emails);
            if (!rowErrors.isEmpty()) errors.add("Dòng " + (i + 1) + ": " + String.join(", ", rowErrors));
        }
        if (!errors.isEmpty()) return new ImportResult(0, request.teachers().size(), "Dữ liệu không hợp lệ", errors);
        for (ImportItem item : request.teachers()) {
            AppUser teacher = new AppUser();
            teacher.setFullName(clean(item.fullName())); teacher.setPhone(clean(item.phone())); teacher.setEmail(emptyToNull(item.email()));
            teacher.setRole("TEACHER"); teacher.setPassword("123456"); teacher.setActive(true); users.save(teacher);
        }
        int count = request.teachers().size();
        return new ImportResult(count, 0, "Đã thêm " + count + " giáo viên", List.of());
    }

    private List<String> validate(String name, String phone, String email, Set<String> phonesInFile, Set<String> emailsInFile) {
        List<String> errors = new ArrayList<>();
        if (name.isBlank()) errors.add("Họ và tên không được để trống");
        if (phone.isBlank()) errors.add("Số điện thoại không được để trống");
        else {
            if (phone.length() > 15) errors.add("Số điện thoại tối đa 15 ký tự");
            if (!phonesInFile.add(phone)) errors.add("Số điện thoại bị trùng trong file");
            if (users.findByPhone(phone).isPresent()) errors.add("Số điện thoại đã tồn tại");
        }
        if (!email.isBlank()) {
            if (!EMAIL.matcher(email).matches()) errors.add("Email không đúng định dạng");
            else {
                if (!emailsInFile.add(email.toLowerCase())) errors.add("Email bị trùng trong file");
                if (users.findByEmail(email).isPresent()) errors.add("Email đã tồn tại");
            }
        }
        return errors;
    }

    private void validateFile(MultipartFile file) {
        if (file == null || file.isEmpty()) throw bad("Vui lòng chọn file Excel");
        String name = Optional.ofNullable(file.getOriginalFilename()).orElse("").toLowerCase();
        if (!name.endsWith(".xlsx")) throw bad("Chỉ hỗ trợ file Excel định dạng .xlsx");
        if (file.getSize() > 5 * 1024 * 1024) throw bad("File Excel không được vượt quá 5 MB");
    }
    private String cell(Row row, int index, DataFormatter formatter) { return row == null ? "" : clean(formatter.formatCellValue(row.getCell(index))); }
    private String clean(String value) { return value == null ? "" : value.trim(); }
    private String emptyToNull(String value) { String cleaned = clean(value); return cleaned.isBlank() ? null : cleaned; }
    private ResponseStatusException bad(String message) { return new ResponseStatusException(HttpStatus.BAD_REQUEST, message); }
}
