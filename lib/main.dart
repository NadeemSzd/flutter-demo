import 'package:flutter/material.dart';
import 'package:flutter_app_db/db_manager.dart';

void main()=> runApp(MaterialApp(
     debugShowCheckedModeBanner: false,
     title: 'SQFLite Demo',
     home: HomePage(),
));

class HomePage extends StatefulWidget
{
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final Db_StudentManager _db_studentManager = new Db_StudentManager();
  final _nameController = TextEditingController();
  final _courseController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  Student student;

  List<Student> studentList;
  int updateIndex;

  @override
  Widget build(BuildContext context)
  {

    double buttonWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('SQFLite'),
      ),

      body: ListView(
        children: <Widget>[
          Form(key: _formKey,
          child:Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText:'Name'
                  ),
                  controller: _nameController,
                  validator: (val)=>val.isNotEmpty?null:'Name Should  not be Empty',
                ),

                TextFormField(
                  decoration: InputDecoration(
                      labelText:'Course'
                  ),
                  controller: _courseController,
                  validator: (val)=>val.isNotEmpty?null:'Course Should  not be Empty',
                ),

                RaisedButton(
                  textColor: Colors.white,
                  color: Colors.blue,
                  child: Container(
                    width: buttonWidth*0.9,
                    child: Text('SUBMIT',textAlign: TextAlign.center,),
                  ),
                  onPressed: ()
                  {
                    _submitStudent(context);
                  },
                ),

                FutureBuilder(
                  future: _db_studentManager.getStudentList(),
                  builder: (context,snapshot)
                  {
                    if(snapshot.hasData)
                      {
                        studentList = snapshot.data;
                        return ListView.builder(
                            itemCount: studentList==null?0:studentList.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context,int index){
                              Student st = studentList[index];
                              return Card(
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      width: buttonWidth*0.65,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text('Name:${st.name}',style: TextStyle(fontSize: 15.0),),
                                          Text('Course:${st.course}',style: TextStyle(fontSize: 15.0,color: Colors.black54),),
                                        ],
                                      ),
                                    ),
                                    IconButton(onPressed: ()
                                    {
                                      _nameController.text = st.name;
                                      _courseController.text = st.course;
                                      student = st;
                                      updateIndex = index;
                                    }
                                    ,icon: Icon(Icons.edit,color: Colors.blue,),),
                                    IconButton(onPressed: ()
                                    {
                                      _db_studentManager.deleteStudent(st.id);
                                      int i = st.id;
                                      String name  = st.name;
                                      print(st.id);
                                      print('Student id to be removed is :$i');
                                      print('Student name to be removed is :$name');
                                      setState(()
                                      {
                                        studentList.removeAt(index);
                                        print('Student removed from index : $index');
                                      });
                                    },
                                      icon: Icon(Icons.delete,color: Colors.red,),)
                                  ],
                                ),
                              );
                            },
                        );
                      }
                    return new CircularProgressIndicator();
                  },
                )
              ],
            ),
          ),
          )
        ],
      ),
    );
  }

  void _submitStudent(BuildContext context)
  {
    if(_formKey.currentState.validate())
      {
        if(student==null)
          {
            Student student = new Student(name: _nameController.text, course: _courseController.text);
            _db_studentManager.insertStudent(student).then((id)=>{
              _nameController.clear(),
              _courseController.clear(),
              print('Student Added to DB ${id}')
            });

            setState(() {
              studentList.add(student);
            });
          }
        else
          {
            student.name = _nameController.text;
            student.course = _courseController.text;

            _db_studentManager.updateStudent(student).then((id)=>{
              setState((){ // ignore: sdk_version_set_literal
                // ignore: sdk_version_set_literal
                studentList[updateIndex].name = _nameController.text;
                studentList[updateIndex].course = _courseController.text;
              }),
              _nameController.clear(),
              _courseController.clear(),
              // ignore: sdk_version_set_literal
              student=null
            });
          }
      }
  }
}
