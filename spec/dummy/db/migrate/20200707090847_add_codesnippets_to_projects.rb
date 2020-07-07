class AddCodesnippetsToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :code_snippet, :text, default: '<!DOCTYPE html>

    <HTML>
        <HEAD>
            <SCRIPT>
                var name = prompt("Enter Your name:");
                var msg = "Welcome "+name;
                //alert(msg);
                document.write(msg);
            </SCRIPT>
        </HEAD>
        <BODY>

        </BODY>
    </HTML>
    '
  end
end
