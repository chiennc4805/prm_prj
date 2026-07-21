import { BookOpen, CalendarDays, ClipboardCheck, School, Users } from 'lucide-react';
import { api } from '../../api';
import { useAuth } from '../../auth';
import { Card, ErrorBox, Loading, Page, Stat, useLoad } from '../../components';

export default function TeacherDashboard() {
  const { user } = useAuth();
  const { data, loading, error, reload } = useLoad(async () => {
    const [assignments, schedule, classes, subjects] = await Promise.all([
      api.get(`/api/teacher/assignments?teacherId=${user.id}`),
      api.get(`/api/teacher/schedule?teacherId=${user.id}`),
      api.get('/api/admin/classes'),
      api.get('/api/admin/subjects'),
    ]);
    const homeroom = classes.filter((c) => c.homeroomTeacherId === user.id);
    return { assignments, schedule, classes, subjects, homeroom };
  }, [user.id]);
  if (loading) return <Loading />;
  if (error) return <ErrorBox error={error} onRetry={reload} />;
  const classIds = [...new Set(data.assignments.map((a) => a.classId))];
  return (
    <Page
      title="Tổng quan giảng dạy"
      subtitle={`Chào ${user.fullName}, chúc thầy/cô một ngày làm việc hiệu quả.`}
    >
      <div className="stats-grid">
        <Stat
          label="Lớp phụ trách"
          value={classIds.length}
          icon={Users}
          tone="blue"
          hint="Theo phân công bộ môn"
        />
        <Stat
          label="Môn giảng dạy"
          value={new Set(data.assignments.map((a) => a.subjectId)).size}
          icon={BookOpen}
          tone="violet"
          hint="Trong năm học hiện tại"
        />
        <Stat
          label="Tiết mỗi tuần"
          value={data.schedule.length}
          icon={CalendarDays}
          tone="orange"
          hint="Đã được xếp lịch"
        />
        <Stat
          label="Lớp chủ nhiệm"
          value={data.homeroom.length}
          icon={School}
          tone="green"
          hint={data.homeroom[0]?.name || 'Không chủ nhiệm'}
        />
      </div>
      <div className="dashboard-grid">
        <Card>
          <div className="card-title">
            <div>
              <h3>Phân công của tôi</h3>
              <p>Lớp và môn học đang phụ trách</p>
            </div>
          </div>
          <div className="assignment-cards">
            {data.assignments.map((a) => (
              <div key={a.id}>
                <span>
                  {data.subjects.find((s) => s.id === a.subjectId)?.name?.slice(0, 1) || 'M'}
                </span>
                <div>
                  <strong>{data.subjects.find((s) => s.id === a.subjectId)?.name}</strong>
                  <small>
                    Lớp {data.classes.find((c) => c.id === a.classId)?.name} · {a.academicYear}
                  </small>
                </div>
              </div>
            ))}
          </div>
        </Card>
        <Card>
          <div className="card-title">
            <div>
              <h3>Ghi chú nhanh</h3>
              <p>Quyền theo vai trò</p>
            </div>
            <ClipboardCheck />
          </div>
          <ul className="check-list">
            <li>Xem học sinh các lớp được phân công</li>
            <li>Nhập và quản lý điểm theo môn</li>
            <li>Gửi thông báo tới lớp phụ trách</li>
            {data.homeroom.length > 0 && (
              <>
                <li>Xem đơn xin nghỉ học</li>
                <li>Đánh giá học sinh cuối kỳ</li>
              </>
            )}
          </ul>
        </Card>
      </div>
    </Page>
  );
}
