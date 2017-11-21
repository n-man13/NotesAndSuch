package helpingStuff;

public class Class {
	private ListInterface<Student> classList;
	private String className;
	
	public Class(String name) {
		className = name;
	}
	
	public void addStudents(ListInterface<Student> l) throws ListException {
		int initSize = classList.size();
		for(int i = 0; i < l.size(); i++) {
			classList.add(initSize + i, l.get(i));
		}
	}
	
	public void addStudent(Student s) throws ListException {
		classList.add(classList.size(), s);
	}
	
	public Student dropStudent(int number) throws ListException {
		Student dropped = null;
		for (int i = 0; i < classList.size(); i++) {
			if (classList.get(i).getNumber() == number)
				dropped = classList.remove(i);
		}
		return dropped;
	}

	public ListInterface<Student> cancelClass(){
		return classList;
	}
}
