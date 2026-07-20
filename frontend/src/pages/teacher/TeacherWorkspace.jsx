import { useState } from 'react';
import { useParams } from 'react-router-dom';
import {
  Bell,
  CalendarCheck,
  Check,
  ClipboardCheck,
  Plus,
  Send,
  Trash2,
  Users,
} from 'lucide-react';
import { api } from '../../api';
import { useAuth } from '../../auth';
import {
  Badge,
  Button,
  Card,
  Empty,
  ErrorBox,
  Field,
  Loading,
  Modal,
  Page,
  Table,
  useLoad,
} from '../../components';

export default function TeacherWorkspace() {
  const { section } = useParams();
  const { user } = useAuth();
  const common = useLoad(async () => {
    const [assignments, schedule, classes, subjects, semesters, allAssignments, allStudents] =
      await Promise.all([
        api.get(`/api/teacher/assignments?teacherId=${user.id}`),
        api.get(`/api/teacher/schedule?teacherId=${user.id}`),
        api.get('/api/admin/classes'),
        api.get('/api/admin/subjects'),
        api.get('/api/admin/semesters'),
        api.get('/api/admin/assignments'),
        api.get('/api/admin/students'),
      ]);
    return {
      assignments,
      schedule,
      classes,
      subjects,
      semesters,
      allAssignments,
      allStudents,
      homeroom: classes.filter((c) => c.homeroomTeacherId === user.id),
    };
  }, [user.id]);
  if (common.loading) return <Loading />;
  if (common.error) return <ErrorBox error={common.error} onRetry={common.reload} />;
  const props = { user, data: common.data };
  if (section === 'schedule') return <Schedule {...props} />;
  if (section === 'classes') return <Classes {...props} />;
  if (section === 'grades') return <Grades {...props} />;
  if (section === 'notifications') return <Notifications {...props} />;
  return <Homeroom {...props} />;
}

const label = (a, d) =>
  `${d.classes.find((c) => c.id === a.classId)?.name} · ${d.subjects.find((s) => s.id === a.subjectId)?.name}`;
function Picker({ assignments, data, value, onChange, labelText = 'Phân công' }) {
  return (
    <Field label={labelText}>
      <select value={value} onChange={(e) => onChange(Number(e.target.value))}>
        <option value="">Chọn lớp và môn...</option>
        {assignments.map((a) => (
          <option key={a.id} value={a.id}>
            {label(a, data)}
          </option>
        ))}
      </select>
    </Field>
  );
}
function Schedule({ data }) {
  const rows = data.schedule.map((s) => {
    const a = data.assignments.find((a) => a.id === s.teacherAssignmentId);
    return {
      ...s,
      className: data.classes.find((c) => c.id === a?.classId)?.name,
      subject: data.subjects.find((x) => x.id === a?.subjectId)?.name,
    };
  });
  return (
    <Page title="Lịch dạy" subtitle="Thời khóa biểu cá nhân theo tuần">
      <Card>
        <Table
          rows={rows}
          columns={[
            {
              key: 'dayOrder',
              label: 'Ngày',
              render: (x) => (x.dayOrder === 8 ? 'Chủ nhật' : `Thứ ${x.dayOrder}`),
            },
            { key: 'period', label: 'Tiết' },
            { key: 'subject', label: 'Môn học' },
            { key: 'className', label: 'Lớp' },
            { key: 'room', label: 'Phòng' },
            { key: 'time', label: 'Thời gian', render: (x) => `${x.startTime} – ${x.endTime}` },
          ]}
        />
      </Card>
    </Page>
  );
}
function Classes({ user, data }) {
  const [selected, setSelected] = useState(data.assignments[0]?.id || '');
  const current = data.assignments.find((a) => a.id === selected);
  const state = useLoad(
    () =>
      selected
        ? api.get(`/api/teacher/assignments/${selected}/students?teacherId=${user.id}`)
        : Promise.resolve([]),
    [selected],
  );
  return (
    <Page title="Lớp giảng dạy" subtitle="Danh sách học sinh theo phân công">
      <Card className="toolbar-card">
        <Picker
          assignments={data.assignments}
          data={data}
          value={selected}
          onChange={setSelected}
        />
        {current && <Badge tone="blue">{state.data?.length || 0} học sinh</Badge>}
      </Card>
      <Card>
        {state.loading ? (
          <Loading />
        ) : (
          <Table
            rows={state.data || []}
            columns={[
              { key: 'studentCode', label: 'Mã HS' },
              { key: 'fullName', label: 'Họ và tên' },
              { key: 'dateOfBirth', label: 'Ngày sinh' },
              {
                key: 'gender',
                label: 'Giới tính',
                render: (x) => (x.gender === 'MALE' ? 'Nam' : 'Nữ'),
              },
            ]}
          />
        )}
      </Card>
    </Page>
  );
}

function Grades({ user, data }) {
  const [selected, setSelected] = useState(data.assignments[0]?.id || '');
  const [semesterId, setSemesterId] = useState(
    data.semesters.find((s) => s.active)?.id || data.semesters[0]?.id || '',
  );
  const [editing, setEditing] = useState(null);
  const state = useLoad(async () => {
    if (!selected || !semesterId) return [];
    const [students, grades] = await Promise.all([
      api.get(`/api/teacher/assignments/${selected}/students?teacherId=${user.id}`),
      api.get(
        `/api/teacher/assignments/${selected}/grades?teacherId=${user.id}&semesterId=${semesterId}`,
      ),
    ]);
    return students.map((s) => ({ ...s, grade: grades.find((g) => g.studentId === s.id) }));
  }, [selected, semesterId]);
  return (
    <Page title="Quản lý điểm" subtitle="Mỗi đầu điểm có một giá trị và trọng số riêng">
      <Card className="toolbar-card">
        <Picker
          assignments={data.assignments}
          data={data}
          value={selected}
          onChange={setSelected}
        />
        <Field label="Học kỳ">
          <select value={semesterId} onChange={(e) => setSemesterId(Number(e.target.value))}>
            {data.semesters.map((s) => (
              <option key={s.id} value={s.id}>
                {s.name} · {s.academicYear}
              </option>
            ))}
          </select>
        </Field>
      </Card>
      <Card>
        {state.loading ? (
          <Loading />
        ) : (
          <Table
            rows={state.data || []}
            columns={[
              {
                key: 'student',
                label: 'Học sinh',
                render: (r) => (
                  <>
                    <strong>{r.fullName}</strong>
                    <small className="block">{r.studentCode}</small>
                  </>
                ),
              },
              { key: 'items', label: 'Số đầu điểm', render: (r) => r.grade?.items?.length || 0 },
              {
                key: 'average',
                label: 'Trung bình',
                render: (r) => <Badge tone="blue">{r.grade?.averageScore ?? '—'}</Badge>,
              },
              {
                key: 'action',
                label: '',
                render: (r) => (
                  <button className="status-select" onClick={() => setEditing(r)}>
                    {r.grade ? 'Sửa điểm' : 'Nhập điểm'}
                  </button>
                ),
              },
            ]}
          />
        )}
      </Card>
      {editing && (
        <GradeEditor
          row={editing}
          close={() => setEditing(null)}
          save={async (items) => {
            await api.put(
              `/api/teacher/assignments/${selected}/students/${editing.id}/grade?teacherId=${user.id}&semesterId=${semesterId}`,
              { items },
            );
            setEditing(null);
            state.reload();
          }}
        />
      )}
    </Page>
  );
}

function GradeEditor({ row, close, save }) {
  const [items, setItems] = useState(
    row.grade?.items?.map(({ name, score, weight }) => ({ name, score, weight })) || [
      { name: 'Kiểm tra 15 phút', score: '', weight: 1 },
    ],
  );
  const [busy, setBusy] = useState(false);
  const change = (i, key, value) =>
    setItems(items.map((x, n) => (n === i ? { ...x, [key]: value } : x)));
  const submit = async (e) => {
    e.preventDefault();
    setBusy(true);
    try {
      await save(items.map((x) => ({ ...x, score: Number(x.score), weight: Number(x.weight) })));
    } catch (error) {
      alert(error.message);
      setBusy(false);
    }
  };
  return (
    <Modal title={`Điểm của ${row.fullName}`} onClose={close}>
      <form className="stack-form" style={{ padding: 23 }} onSubmit={submit}>
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Đầu điểm</th>
                <th>Điểm</th>
                <th>Trọng số</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {items.map((item, i) => (
                <tr key={i}>
                  <td>
                    <input
                      value={item.name}
                      onChange={(e) => change(i, 'name', e.target.value)}
                      required
                    />
                  </td>
                  <td>
                    <input
                      className="score-input"
                      type="number"
                      min="0"
                      max="10"
                      step="0.01"
                      value={item.score}
                      onChange={(e) => change(i, 'score', e.target.value)}
                      required
                    />
                  </td>
                  <td>
                    <input
                      className="score-input"
                      type="number"
                      min="0.01"
                      step="0.01"
                      value={item.weight}
                      onChange={(e) => change(i, 'weight', e.target.value)}
                      required
                    />
                  </td>
                  <td>
                    <button
                      type="button"
                      className="danger"
                      onClick={() => setItems(items.filter((_, n) => n !== i))}
                    >
                      <Trash2 size={15} />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <Button
          type="button"
          variant="ghost"
          onClick={() => setItems([...items, { name: '', score: '', weight: 1 }])}
        >
          <Plus size={16} /> Thêm đầu điểm
        </Button>
        <div className="form-actions">
          <Button type="button" variant="ghost" onClick={close}>
            Hủy
          </Button>
          <Button disabled={busy || !items.length}>{busy ? 'Đang lưu...' : 'Lưu điểm'}</Button>
        </div>
      </form>
    </Modal>
  );
}

function Notifications({ user, data }) {
  const classIds = [
    ...new Set(data.assignments.map((a) => a.classId).concat(data.homeroom.map((c) => c.id))),
  ];
  const [form, setForm] = useState({ classId: classIds[0] || '', title: '', content: '' });
  const send = async (e) => {
    e.preventDefault();
    await api.post(`/api/teacher/classes/${form.classId}/notifications?teacherId=${user.id}`, form);
    setForm({ ...form, title: '', content: '' });
    alert('Đã gửi thông báo');
  };
  return (
    <Page title="Gửi thông báo" subtitle="Thông báo tới các lớp thầy/cô đang phụ trách">
      <div className="narrow">
        <Card>
          <form className="stack-form" onSubmit={send}>
            <Field label="Lớp nhận">
              <select
                value={form.classId}
                onChange={(e) => setForm({ ...form, classId: Number(e.target.value) })}
              >
                {classIds.map((id) => (
                  <option key={id} value={id}>
                    {data.classes.find((c) => c.id === id)?.name}
                  </option>
                ))}
              </select>
            </Field>
            <Field label="Tiêu đề">
              <input
                value={form.title}
                onChange={(e) => setForm({ ...form, title: e.target.value })}
                required
              />
            </Field>
            <Field label="Nội dung">
              <textarea
                rows="7"
                value={form.content}
                onChange={(e) => setForm({ ...form, content: e.target.value })}
                required
              />
            </Field>
            <Button>
              <Send size={17} /> Gửi thông báo
            </Button>
          </form>
        </Card>
      </div>
    </Page>
  );
}

function Homeroom({ user, data }) {
  const [classId, setClassId] = useState(data.homeroom[0]?.id || '');
  const [tab, setTab] = useState('leaves');
  if (!data.homeroom.length)
    return (
      <Page title="Công tác chủ nhiệm">
        <Card>
          <Empty text="Thầy/cô hiện không được phân công chủ nhiệm lớp nào" />
        </Card>
      </Page>
    );
  return (
    <Page title="Công tác chủ nhiệm" subtitle="Duyệt đơn, xem điểm tổng hợp và đánh giá học sinh">
      <Card className="toolbar-card">
        <Field label="Lớp chủ nhiệm">
          <select value={classId} onChange={(e) => setClassId(Number(e.target.value))}>
            {data.homeroom.map((c) => (
              <option key={c.id} value={c.id}>
                {c.name}
              </option>
            ))}
          </select>
        </Field>
        <div className="tabs">
          <button className={tab === 'leaves' ? 'active' : ''} onClick={() => setTab('leaves')}>
            Đơn xin nghỉ
          </button>
          <button className={tab === 'grades' ? 'active' : ''} onClick={() => setTab('grades')}>
            Bảng điểm lớp
          </button>
          <button
            className={tab === 'evaluation' ? 'active' : ''}
            onClick={() => setTab('evaluation')}
          >
            Đánh giá cuối kỳ
          </button>
        </div>
      </Card>
      {tab === 'leaves' ? (
        <Leaves user={user} classId={classId} data={data} />
      ) : tab === 'grades' ? (
        <ClassGrades user={user} classId={classId} data={data} />
      ) : (
        <Evaluations user={user} classId={classId} data={data} />
      )}
    </Page>
  );
}
function Leaves({ user, classId, data }) {
  const state = useLoad(
    () => api.get(`/api/teacher/homeroom/${classId}/leaves?teacherId=${user.id}`),
    [classId],
  );
  const review = async (id, status) => {
    await api.put(`/api/teacher/homeroom/${classId}/leaves/${id}?teacherId=${user.id}`, {
      status,
      rejectionReason: status === 'REJECTED' ? 'GVCN từ chối đơn' : null,
    });
    state.reload();
  };
  return (
    <Card>
      {state.loading ? (
        <Loading />
      ) : (
        <Table
          rows={state.data || []}
          columns={[
            {
              key: 'studentId',
              label: 'Học sinh',
              render: (x) =>
                data.allStudents.find((s) => s.id === x.studentId)?.fullName ||
                `HS #${x.studentId}`,
            },
            { key: 'date', label: 'Thời gian', render: (x) => `${x.fromDate} → ${x.toDate}` },
            { key: 'reason', label: 'Lý do' },
            {
              key: 'status',
              label: 'Trạng thái',
              render: (x) => (
                <Badge
                  tone={
                    x.status === 'APPROVED' ? 'green' : x.status === 'REJECTED' ? 'red' : 'orange'
                  }
                >
                  {x.status}
                </Badge>
              ),
            },
            {
              key: 'actions',
              label: '',
              render: (x) =>
                x.status === 'PENDING' ? (
                  <div className="row-actions">
                    <button onClick={() => review(x.id, 'APPROVED')}>
                      <Check size={15} /> Duyệt
                    </button>
                    <button className="danger" onClick={() => review(x.id, 'REJECTED')}>
                      Từ chối
                    </button>
                  </div>
                ) : null,
            },
          ]}
        />
      )}
    </Card>
  );
}
function ClassGrades({ user, classId, data }) {
  const state = useLoad(
    () => api.get(`/api/teacher/homeroom/${classId}/grades?teacherId=${user.id}`),
    [classId],
  );
  return (
    <Card>
      {state.loading ? (
        <Loading />
      ) : (
        <Table
          rows={state.data || []}
          columns={[
            {
              key: 'studentId',
              label: 'Học sinh',
              render: (x) =>
                data.allStudents.find((s) => s.id === x.studentId)?.fullName ||
                `HS #${x.studentId}`,
            },
            {
              key: 'subject',
              label: 'Môn học',
              render: (x) => {
                const a = data.allAssignments.find((a) => a.id === x.teacherAssignmentId);
                return (
                  data.subjects.find((s) => s.id === a?.subjectId)?.name ||
                  `#${x.teacherAssignmentId}`
                );
              },
            },
            {
              key: 'semesterId',
              label: 'Học kỳ',
              render: (x) => data.semesters.find((s) => s.id === x.semesterId)?.name || '—',
            },
            { key: 'items', label: 'Số đầu điểm', render: (x) => x.items?.length || 0 },
            { key: 'averageScore', label: 'Trung bình' },
          ]}
        />
      )}
    </Card>
  );
}
function Evaluations({ user, classId, data }) {
  const semester = data.semesters.find((s) => s.active) || data.semesters[0];
  const roster = useLoad(async () => {
    if (!semester) return [];
    const evaluations = await api.get(
      `/api/teacher/homeroom/${classId}/evaluations?teacherId=${user.id}&semesterId=${semester.id}`,
    );
    return data.allStudents
      .filter((s) => s.classId === classId)
      .map((s) => ({ ...s, evaluation: evaluations.find((e) => e.studentId === s.id) }));
  }, [classId, semester?.id]);
  const save = async (row, rating) => {
    await api.put(
      `/api/teacher/homeroom/${classId}/students/${row.id}/evaluation?teacherId=${user.id}&semesterId=${semester.id}`,
      {
        conductRating: rating,
        academicRating: row.evaluation?.academicRating || null,
        comment: row.evaluation?.comment || '',
      },
    );
    roster.reload();
  };
  return (
    <Card>
      {roster.loading ? (
        <Loading />
      ) : (
        <Table
          rows={roster.data || []}
          columns={[
            { key: 'studentCode', label: 'Mã HS' },
            { key: 'fullName', label: 'Họ và tên' },
            {
              key: 'conduct',
              label: 'Hạnh kiểm',
              render: (r) => (
                <select
                  className="status-select"
                  value={r.evaluation?.conductRating || ''}
                  onChange={(e) => save(r, e.target.value)}
                >
                  <option value="">Chọn...</option>
                  <option value="EXCELLENT">Tốt</option>
                  <option value="GOOD">Khá</option>
                  <option value="AVERAGE">Trung bình</option>
                  <option value="WEAK">Yếu</option>
                </select>
              ),
            },
          ]}
        />
      )}
    </Card>
  );
}
