package helpingStuff;

public class Registrar {
	private ListInterface<Student> allStudents;
	private ListInterface<Class> allClasses;
	
	public Registrar(ListInterface<Student> curStudents) {
		allStudents = curStudents;
	}
	
	public void addStudent(Student s) throws ListException {
		allStudents.add(0, s);
	}
}
