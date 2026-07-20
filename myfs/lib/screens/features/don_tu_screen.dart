import 'package:flutter/material.dart';
import '../../models/leave_request.dart';
import '../../models/student.dart';
import '../../services/leave_service.dart';
import '../../services/session.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui_helpers.dart';

class DonTuScreen extends StatefulWidget {
  const DonTuScreen({super.key});
  @override State<DonTuScreen> createState() => _DonTuScreenState();
}

class _DonTuScreenState extends State<DonTuScreen> {
  Student? get student => Session.instance.currentStudent;
  late Future<List<LeaveRequest>> future;
  @override void initState(){super.initState();future=load();}
  Future<List<LeaveRequest>> load()=>student==null?Future.value([]):LeaveService.byStudent(student!.id);
  void reload()=>setState(()=>future=load());
  Future<void> openForm() async {if(!Session.instance.isParent||student==null)return;final ok=await Navigator.push<bool>(context,MaterialPageRoute(builder:(_)=>_LeaveForm(student:student!)));if(ok==true)reload();}

  @override Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(title:Text(student==null?'Đơn xin nghỉ học':'Đơn xin nghỉ • ${student!.fullName}')),
      body:student==null?const EmptyView(icon:Icons.person_off_outlined,message:'Không xác định được học sinh.'):
        FutureBuilder<List<LeaveRequest>>(future:future,builder:(context,snapshot){
          if(snapshot.connectionState==ConnectionState.waiting)return const LoadingView();
          if(snapshot.hasError)return ErrorView(message:snapshot.error.toString(),onRetry:reload);
          final rows=snapshot.data??[];
          if(rows.isEmpty)return EmptyView(icon:Icons.description_outlined,message:'Chưa có đơn xin nghỉ học.',action:FilledButton.icon(onPressed:openForm,icon:const Icon(Icons.add),label:const Text('Tạo đơn')));
          return RefreshIndicator(onRefresh:()async=>reload(),child:ListView.builder(padding:const EdgeInsets.all(16),itemCount:rows.length,itemBuilder:(_,i)=>_card(rows[i])));
        }),
      floatingActionButton:Session.instance.isParent&&student!=null?FloatingActionButton.extended(onPressed:openForm,icon:const Icon(Icons.add),label:const Text('Tạo đơn')):null,
    );
  }

  Widget _card(LeaveRequest r){
    final color=r.status=='APPROVED'?AppColors.success:r.status=='REJECTED'?AppColors.danger:AppColors.warning;
    final date=r.fromDate==r.toDate?r.fromDate:'${r.fromDate} → ${r.toDate}';
    return Card(margin:const EdgeInsets.only(bottom:12),child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[const Icon(Icons.event_busy,color:AppColors.primary),const SizedBox(width:8),const Expanded(child:Text('Đơn xin nghỉ học',style:TextStyle(fontWeight:FontWeight.bold))),Chip(label:Text(LeaveRequest.label(r.status)),backgroundColor:color.withValues(alpha:.12))]),
      const SizedBox(height:8),Text('Thời gian: $date'),const SizedBox(height:6),Text('Lý do: ${r.reason}'),
    ])));
  }
}

class _LeaveForm extends StatefulWidget {
  final Student student;
  const _LeaveForm({required this.student});
  @override State<_LeaveForm> createState()=>_LeaveFormState();
}

class _LeaveFormState extends State<_LeaveForm>{
  final formKey=GlobalKey<FormState>();final reason=TextEditingController();DateTime from=DateTime.now(),to=DateTime.now();bool saving=false;
  String fmt(DateTime d)=>'${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
  Future<void> pick(bool start)async{final value=await showDatePicker(context:context,initialDate:start?from:to,firstDate:DateTime.now(),lastDate:DateTime.now().add(const Duration(days:365)));if(value!=null)setState((){if(start){from=value;if(to.isBefore(from))to=from;}else{to=value;}});}
  Future<void> submit()async{if(!formKey.currentState!.validate())return;setState(()=>saving=true);try{await LeaveService.create(LeaveRequest(studentId:widget.student.id,studentCode:widget.student.studentCode,studentName:widget.student.fullName,className:widget.student.className,fromDate:fmt(from),toDate:fmt(to),reason:reason.text.trim(),createdById:Session.instance.user!.id));if(mounted)Navigator.pop(context,true);}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Lỗi: $e')));setState(()=>saving=false);}}
  @override void dispose(){reason.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Tạo đơn xin nghỉ học')),body:Form(key:formKey,child:ListView(padding:const EdgeInsets.all(20),children:[
    Text(widget.student.fullName,style:Theme.of(context).textTheme.titleLarge),const SizedBox(height:20),
    ListTile(onTap:()=>pick(true),leading:const Icon(Icons.calendar_today),title:const Text('Từ ngày'),subtitle:Text(fmt(from))),
    ListTile(onTap:()=>pick(false),leading:const Icon(Icons.event),title:const Text('Đến ngày'),subtitle:Text(fmt(to))),const SizedBox(height:16),
    TextFormField(controller:reason,maxLines:4,decoration:const InputDecoration(labelText:'Lý do nghỉ học',border:OutlineInputBorder()),validator:(v)=>v==null||v.trim().isEmpty?'Vui lòng nhập lý do':null),const SizedBox(height:24),
    FilledButton(onPressed:saving?null:submit,child:Text(saving?'Đang gửi...':'Gửi đến GVCN')),
  ])));
}
