import { BookOpen, CalendarDays, GraduationCap, School, Users } from 'lucide-react';
import { api } from '../../api';
import { Card, ErrorBox, Loading, Page, Stat, useLoad } from '../../components';

export default function AdminDashboard() {
  const { data, loading, error, reload } = useLoad(async () => {
    const [users, students, classes, subjects, schedules] = await Promise.all(
      [
        '/api/admin/users',
        '/api/admin/students',
        '/api/admin/classes',
        '/api/admin/subjects',
        '/api/admin/schedules',
      ].map(api.get),
    );
    return { users, students, classes, subjects, schedules };
  });
  if (loading) return <Loading />;
  if (error) return <ErrorBox error={error} onRetry={reload} />;
  const teachers = data.users.filter((x) => x.role === 'TEACHER');
  return (
    <Page title="Tổng quan" subtitle="Theo dõi nhanh tình hình vận hành trường học">
      <div className="stats-grid">
        <Stat
          label="Giáo viên"
          value={teachers.length}
          icon={Users}
          tone="violet"
          hint="Tài khoản đang quản lý"
        />
        <Stat
          label="Học sinh"
          value={data.students.length}
          icon={GraduationCap}
          tone="blue"
          hint="Trong toàn trường"
        />
        <Stat
          label="Lớp học"
          value={data.classes.length}
          icon={School}
          tone="green"
          hint="Năm học hiện tại"
        />
        <Stat
          label="Môn học"
          value={data.subjects.length}
          icon={BookOpen}
          tone="orange"
          hint="Đang được sử dụng"
        />
      </div>
      <div className="dashboard-grid">
        <Card>
          <div className="card-title">
            <div>
              <h3>Lớp học gần đây</h3>
              <p>Thông tin lớp và giáo viên chủ nhiệm</p>
            </div>
          </div>
          <div className="class-list">
            {data.classes.map((c) => (
              <div className="class-row" key={c.id}>
                <div className="class-symbol">{c.name.slice(0, 2)}</div>
                <div>
                  <strong>{c.name}</strong>
                  <small>Năm học {c.academicYear}</small>
                </div>
                <span>
                  {teachers.find((t) => t.id === c.homeroomTeacherId)?.fullName || 'Chưa có GVCN'}
                </span>
              </div>
            ))}
          </div>
        </Card>
        <Card>
          <div className="card-title">
            <div>
              <h3>Khối lượng lịch học</h3>
              <p>Các tiết đã được xếp lịch</p>
            </div>
            <CalendarDays />
          </div>
          <div className="big-number">{data.schedules.length}</div>
          <div className="progress">
            <i style={{ width: `${Math.min(100, data.schedules.length * 8)}%` }} />
          </div>
          <p className="muted">Có thể tiếp tục xếp lịch tại mục Thời khóa biểu.</p>
        </Card>
      </div>
    </Page>
  );
}
