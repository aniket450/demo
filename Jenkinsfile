pipeline {
    agent any
    stages {
		stage('Model Advisory Check') {
            steps {
				echo 'Deleting the previous zip files'
				bat 'python del_zip.py'
				echo 'Model checks for ISO 26262'
				echo 'MAAB guidelines check are triggered'
				bat 'python before_run.py'
				bat '"C:\\Program Files\\MATLAB\\R2016b\\bin\\matlab.exe" -wait -nodisplay -nosplash -nodesktop -r " try, run(\'advisory_check.m\'), catch, exit(1), end;"'
				bat 'python after_run.py advisory_check_report'
				echo 'Model Advisory Check Completed'
            }
        }
        stage('Static MIL Test') {
            steps {
				bat 'python before_run.py'
				echo 'static MIL test in process'
				bat '"C:\\Program Files\\MATLAB\\R2016b\\bin\\matlab.exe" -wait -nodisplay -nosplash -nodesktop -r " try, run(\'sldv_check.m\'), catch, exit(1), end;"'
				bat 'python after_run.py static_mil_test'
				echo 'static MIL test Completed'
			}
        }
		stage('Perform MIL Test') {
            steps {
				bat 'python before_run.py'
				echo 'MIL test in process'
				bat '"C:\\Program Files\\MATLAB\\R2016b\\bin\\matlab.exe" -wait -nodisplay -nosplash -nodesktop -r " try, run(\'mil_test.m\'), catch, exit(1), end;"'
				echo 'Perform MIL test Completed'
			}
        }
		stage('Perform SIL Test') {
            steps {
				bat 'python before_run.py'
				echo 'perform SIL test in progress'
				bat '"C:\\Program Files\\MATLAB\\R2016b\\bin\\matlab.exe" -wait -nodisplay -nosplash -nodesktop -r " try, run(\'sil_test.m\'), catch, exit(1), end;"'
				bat 'python after_run.py sil_test'
				echo 'Perform SIL Test Completed'
            }
        }		
		stage('Send Mail') {
			steps {
				bat 'python grp_zip.py'
				echo 'Send Email in progress'
				echo 'Send Email Completed' 				
			}
		}
		
    }
}