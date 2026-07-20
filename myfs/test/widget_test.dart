import 'package:flutter_test/flutter_test.dart';

import 'package:project/main.dart';

void main() {
  testWidgets('màn hình Login hiển thị đúng (chỉ đăng nhập bằng số điện thoại)',
      (tester) async {
    await tester.pumpWidget(const ENetVietApp());

    // Có tiêu đề "Đăng nhập" và ô số điện thoại
    expect(find.text('Đăng nhập'), findsWidgets);
    expect(find.text('Số điện thoại'), findsOneWidget);
    expect(
      find.text('Copyright © 2026 FPT Student Life. All rights reserved.'),
      findsOneWidget,
    );

    // Không có đăng ký / Google
    expect(find.text('Đăng ký ngay'), findsNothing);
    expect(find.text('Tiếp tục với Google'), findsNothing);
  });
}
