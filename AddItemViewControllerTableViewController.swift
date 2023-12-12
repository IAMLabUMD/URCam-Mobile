import UIKit

class AddItemViewController: UITableViewController, UITextFieldDelegate  {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
    }
    
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    // Adding a new item
    @IBAction func done() {
    
    navigationController?.popViewController(animated:true)
    }
    
    //keyboard appears automatically
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    @IBOutlet weak var textField: UITableViewCell!
    
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    
    
    func textField(_ textField: UITextField,
                      shouldChangeCharactersIn range: NSRange,
                      replacementString string: String) -> Bool {
        
        let oldText = textField.text!
        let stringRange = Range(range, in:oldText)!
        let newText = oldText.replacingCharacters(in: stringRange,
                                                  with: string)
        if newText.isEmpty {
            doneBarButton.isEnabled = false
        } else {
            doneBarButton.isEnabled = true
        }
        return true
    }
}

