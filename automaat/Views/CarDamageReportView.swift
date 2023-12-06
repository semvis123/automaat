import SwiftUI
import PhotosUI

struct CarDamageReportView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var image: UIImage? = nil
    @State var description: String = ""
    @State var selectImage = false
    
    var body: some View {
        VStack {
            Text("Schade melden")
                .font(.title2)
                .padding()
            VStack(alignment: .leading) {
                Text("Opmerking")
                TextField(text: $description) {
                    Text("max. 300 karakters")
                }
                .frame(width: .none, height: 40)
                .font(.system(size: 20, weight: .regular))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            
            Button("Foto uploaden") {
                selectImage = true
            }
            .buttonStyle(.borderedProminent)
            .sheet(isPresented: $selectImage) {
                ImagePicker(selectedImage: $image)
            }
            
            ZStack {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    Text("Geen foto geselecteerd")
                }
            }
            .frame(width: 300,height: 300)
            .overlay(
                RoundedRectangle(cornerRadius: 5).stroke(.white)
            )
            Spacer()
        }
        .toolbar {
            Button("Verzenden") {
                print("Sending....")
                self.presentationMode.wrappedValue.dismiss()
            }
            .disabled(image == nil || description == "")
        }
        
    }
}

#Preview {
    CarDamageReportView()
}

// https://medium.com/@vinodh_36508/how-to-integrate-a-uikit-viewcontroller-in-swiftui-b45b2725cdd
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
