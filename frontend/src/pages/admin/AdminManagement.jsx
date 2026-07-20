import { useMemo, useState } from 'react';
import { useParams } from 'react-router-dom';
import { Plus, Trash2 } from 'lucide-react';
import { api } from '../../api';
import { Badge, Button, Card, ErrorBox, Field, Loading, Modal, Page, Table, useLoad } from '../../components';

const titles = {
  teachers: ['Quản lý giáo viên', 'Danh sách giáo viên và thông tin liên hệ'],
  students: ['Quản lý học sinh', 'Danh sách học sinh, lớp học và phụ huynh'],
  parents: ['Quản lý phụ huynh', 'Danh sách phụ huynh trong hệ thống'],
  classes: ['Quản lý lớp học', 'Tổ chức lớp và phân công giáo viên chủ nhiệm'],
  subjects: ['Danh sách môn học', 'Quản lý các môn học đang giảng dạy'],
  assignments: ['Phân công giảng dạy', 'Gán giáo viên, lớp, môn học và học kỳ'],
  schedules: ['Thời khóa biểu', 'Xếp lịch dạy theo phân công giáo viên'],
};

export default function AdminManagement() {
  const { section } = useParams();
  const { data, loading, error, reload } = useLoad(async () => {
    const paths = {
      teachers: '/api/admin/users?role=TEACHER',
      parents: '/api/admin/users?role=PARENT',
      students: '/api/admin/students',
      classes: '/api/admin/classes',
      subjects: '/api/admin/subjects',
      assignments: '/api/admin/assignments',
      schedules: '/api/admin/schedules',
    };
    const [rows, users, students, classes, subjects, semesters, assignments] = await Promise.all([
      api.get(paths[section]),
      api.get('/api/admin/users'),
      api.get('/api/admin/students'),
      api.get('/api/admin/classes'),
      api.get('/api/admin/subjects'),
      api.get('/api/admin/semesters'),
      api.get('/api/admin/assignments'),
    ]);
    return { rows, users, students, classes, subjects, semesters, assignments };
  }, [section]);
  const [modal, setModal] = useState(false);
  const [edit, setEdit] = useState(null);

  if (loading) return <Loading />;
  if (error) return <ErrorBox error={error} onRetry={reload} />;

  const open = (row) => {
    setEdit(row || null);
    setModal(true);
  };
  const userSection = ['teachers', 'parents'].includes(section);
  const remove = async (row) => {
    if (!confirm('Bạn chắc chắn muốn xóa mục này?')) return;
    await api.delete(`/api/admin/${userSection ? 'users' : section}/${row.id}`);
    reload();
  };

  return <Page
    title={titles[section]?.[0] || 'Quản lý'}
    subtitle={titles[section]?.[1]}
    action={<Button onClick={() => open(null)}><Plus size={17} /> Thêm mới</Button>}
  >
    <Card><Table columns={columnsFor(section, data, open, remove)} rows={data.rows} /></Card>
    {modal && <Editor section={section} value={edit} refs={data} close={() => setModal(false)} saved={() => { setModal(false); reload(); }} />}
  </Page>;
}

function columnsFor(section, refs, edit, remove) {
  const actions = { key: 'actions', label: '', render: (row) => <div className="row-actions"><button onClick={() => edit(row)}>Sửa</button><button className="danger" onClick={() => remove(row)}><Trash2 size={15} /></button></div> };
  if (['teachers', 'parents'].includes(section)) return [
    { key: 'name', label: 'Họ tên', render: (row) => { const name = row?.fullName || 'Chưa cập nhật'; return <div className="person"><span>{name.charAt(0) || '?'}</span><div><strong>{name}</strong><small>{row?.email || '—'}</small></div></div>; } },
    { key: 'phone', label: 'Số điện thoại' },
    { key: 'active', label: 'Trạng thái', render: (row) => <Badge tone={row?.active ? 'green' : 'red'}>{row?.active ? 'Hoạt động' : 'Đã khóa'}</Badge> },
    actions,
  ];
  if (section === 'students') return [
    { key: 'studentCode', label: 'Mã HS' },
    { key: 'fullName', label: 'Họ tên' },
    { key: 'phone', label: 'Số điện thoại', render: (row) => refs.users.find((user) => user.id === row.studentAccountId)?.phone || '—' },
    { key: 'classId', label: 'Lớp', render: (row) => refs.classes.find((item) => item.id === row.classId)?.name || '—' },
    { key: 'parentId', label: 'Phụ huynh', render: (row) => refs.users.find((user) => user.id === row.parentId)?.fullName || '—' },
    actions,
  ];
  if (section === 'classes') return [
    { key: 'name', label: 'Tên lớp' },
    { key: 'academicYear', label: 'Năm học' },
    { key: 'homeroomTeacherId', label: 'Giáo viên chủ nhiệm', render: (row) => refs.users.find((user) => user.id === row.homeroomTeacherId)?.fullName || 'Chưa phân công' },
    actions,
  ];
  if (section === 'subjects') return [
    { key: 'code', label: 'Mã môn' }, { key: 'name', label: 'Tên môn học' }, { key: 'description', label: 'Mô tả' },
    { key: 'active', label: 'Trạng thái', render: (row) => <Badge tone={row.active ? 'green' : 'red'}>{row.active ? 'Đang dùng' : 'Tạm dừng'}</Badge> }, actions,
  ];
  if (section === 'assignments') return [
    { key: 'teacherId', label: 'Giáo viên', render: (row) => refs.users.find((user) => user.id === row.teacherId)?.fullName || '—' },
    { key: 'classId', label: 'Lớp', render: (row) => refs.classes.find((item) => item.id === row.classId)?.name || '—' },
    { key: 'subjectId', label: 'Môn', render: (row) => refs.subjects.find((item) => item.id === row.subjectId)?.name || '—' },
    { key: 'semesterId', label: 'Học kỳ', render: (row) => refs.semesters.find((item) => item.id === row.semesterId)?.name || '—' }, actions,
  ];
  return [
    { key: 'dayOrder', label: 'Thứ', render: (row) => row.dayOrder === 8 ? 'Chủ nhật' : `Thứ ${row.dayOrder}` },
    { key: 'period', label: 'Tiết' },
    { key: 'teacherAssignmentId', label: 'Phân công', render: (row) => { const assignment = refs.assignments.find((item) => item.id === row.teacherAssignmentId); return `${refs.classes.find((item) => item.id === assignment?.classId)?.name || '—'} · ${refs.subjects.find((item) => item.id === assignment?.subjectId)?.name || '—'}`; } },
    { key: 'room', label: 'Phòng' },
    { key: 'startTime', label: 'Thời gian', render: (row) => `${row.startTime || '—'} – ${row.endTime || '—'}` }, actions,
  ];
}

function Editor({ section, value, refs, close, saved }) {
  const initial = useMemo(() => {
    if (section === 'students' && value) {
      const account = refs.users.find((user) => user.id === value.studentAccountId);
      return { ...value, phone: account?.phone || '' };
    }
    return value || defaults(section);
  }, [section, value, refs]);
  const [form, setForm] = useState(initial);
  const [busy, setBusy] = useState(false);
  const set = (key, nextValue) => setForm((current) => ({ ...current, [key]: nextValue }));
  const submit = async (event) => {
    event.preventDefault();
    setBusy(true);
    try {
      const userSection = ['teachers', 'parents'].includes(section);
      const resource = userSection ? 'users' : section;
      const payload = userSection ? {
        ...form,
        role: section === 'teachers' ? 'TEACHER' : 'PARENT',
        ...(value ? {} : { password: '123456' }),
        active: form.active ?? true,
      } : form;
      const path = `/api/admin/${resource}${value ? `/${value.id}` : ''}`;
      await (value ? api.put(path, payload) : api.post(path, payload));
      saved();
    } catch (error) {
      alert(error.message);
      setBusy(false);
    }
  };
  return <Modal title={`${value ? 'Cập nhật' : 'Thêm'} ${titles[section]?.[0].toLowerCase()}`} onClose={close}>
    <form className="form-grid" onSubmit={submit}>
      {fields(section, form, set, refs)}
      <div className="form-actions"><Button type="button" variant="ghost" onClick={close}>Hủy</Button><Button disabled={busy}>{busy ? 'Đang lưu...' : 'Lưu thông tin'}</Button></div>
    </form>
  </Modal>;
}

const input = (label, key, form, set, type = 'text', required = true) => <Field label={label}><input type={type} value={form[key] ?? ''} onChange={(event) => set(key, type === 'number' ? Number(event.target.value) : event.target.value)} required={required} /></Field>;
const select = (label, key, form, set, items, text) => <Field label={label}><select value={form[key] ?? ''} onChange={(event) => set(key, Number(event.target.value))} required><option value="">Chọn...</option>{items.map((item) => <option key={item.id} value={item.id}>{text(item)}</option>)}</select></Field>;

function fields(section, form, set, refs) {
  if (['teachers', 'parents'].includes(section)) return <>{input('Họ và tên', 'fullName', form, set)}{input('Số điện thoại', 'phone', form, set)}{input('Email', 'email', form, set, 'email', false)}</>;
  if (section === 'students') return <>{input('Mã học sinh', 'studentCode', form, set)}{input('Họ và tên', 'fullName', form, set)}{input('Số điện thoại', 'phone', form, set)}{input('Ngày sinh', 'dateOfBirth', form, set, 'date')}<Field label="Giới tính"><select value={form.gender} onChange={(event) => set('gender', event.target.value)}><option value="MALE">Nam</option><option value="FEMALE">Nữ</option></select></Field>{select('Lớp', 'classId', form, set, refs.classes, (item) => item.name)}{select('Phụ huynh', 'parentId', form, set, refs.users.filter((item) => item.role === 'PARENT'), (item) => item.fullName)}</>;
  if (section === 'classes') return <>{input('Tên lớp', 'name', form, set)}{input('Năm học', 'academicYear', form, set)}{select('Giáo viên chủ nhiệm', 'homeroomTeacherId', form, set, refs.users.filter((item) => item.role === 'TEACHER'), (item) => item.fullName)}</>;
  if (section === 'subjects') return <>{input('Mã môn', 'code', form, set)}{input('Tên môn học', 'name', form, set)}{input('Mô tả', 'description', form, set)}</>;
  if (section === 'assignments') return <>{select('Giáo viên', 'teacherId', form, set, refs.users.filter((item) => item.role === 'TEACHER'), (item) => item.fullName)}{select('Lớp', 'classId', form, set, refs.classes, (item) => item.name)}{select('Môn học', 'subjectId', form, set, refs.subjects, (item) => item.name)}{select('Học kỳ', 'semesterId', form, set, refs.semesters, (item) => `${item.name} · ${item.academicYear}`)}</>;
  return <>{select('Phân công', 'teacherAssignmentId', form, set, refs.assignments, (assignment) => `${refs.classes.find((item) => item.id === assignment.classId)?.name} · ${refs.subjects.find((item) => item.id === assignment.subjectId)?.name}`)}{input('Thứ (2-8)', 'dayOrder', form, set, 'number')}{input('Tiết', 'period', form, set, 'number')}{input('Phòng', 'room', form, set)}{input('Bắt đầu', 'startTime', form, set, 'time')}{input('Kết thúc', 'endTime', form, set, 'time')}</>;
}

function defaults(section) {
  if (['teachers', 'parents'].includes(section)) return { fullName: '', phone: '', email: '', active: true };
  if (section === 'students') return { studentCode: '', fullName: '', phone: '', dateOfBirth: '', gender: 'MALE', classId: '', parentId: '' };
  if (section === 'classes') return { name: '', academicYear: '2026-2027', homeroomTeacherId: '' };
  if (section === 'subjects') return { code: '', name: '', description: '', active: true };
  if (section === 'assignments') return { teacherId: '', classId: '', subjectId: '', semesterId: '' };
  return { teacherAssignmentId: '', dayOrder: 2, period: 1, room: '', startTime: '07:00', endTime: '07:45' };
}
