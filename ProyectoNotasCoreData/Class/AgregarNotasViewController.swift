//
//  AgregarNotasViewController.swift
//  ProyectoNotasCoreData
//
//  Created by user on 14/4/21.
//

import UIKit
import CoreData
class AgregarNotasViewController: UIViewController {

    @IBOutlet weak var tituloTxt: UITextField!
    @IBOutlet weak var textoTxt: UITextView!
    
    
    var categoriaAddNota : Categorias!
    var notas: Notas!
    var editarGuardar : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if editarGuardar {
            let buttonSave = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(agregarNota))
            navigationItem.rightBarButtonItem = buttonSave
        }else{
            let buttonEdit = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editarNota))
            navigationItem.rightBarButtonItem = buttonEdit
            tituloTxt.text = notas.titulo
            textoTxt.text = notas.texto
        }
        
    }
    @objc func agregarNota(){
        let contexto = Conexion().contexto()
        let entityNotas = NSEntityDescription.insertNewObject(forEntityName: "Notas", into: contexto) as! Notas
        
        entityNotas.id = UUID()
        entityNotas.id_categoria = categoriaAddNota.id
        entityNotas.titulo = tituloTxt.text
        entityNotas.texto = textoTxt.text
        entityNotas.fecha = Date()
        
        categoriaAddNota.mutableSetValue(forKey: "relationToNotas").add(entityNotas)
        
        do {
            try contexto.save()
            print("Guardó")
            //Para volver a nuestra tabla
            navigationController?.popViewController(animated: true)
        } catch let error as NSError {
            print("Hubo un error al guardar Nota", error.localizedDescription)
        }
    }
    @objc func editarNota(){
        let contexto = Conexion().contexto()
        notas.setValue(tituloTxt.text, forKey: "titulo")
        notas.setValue(textoTxt.text, forKey: "texto")
        notas.setValue(Date(), forKey: "fecha")
        
        do {
            try contexto.save()
            print("Guardó")
            //Para volver a nuestra tabla
            navigationController?.popViewController(animated: true)
        } catch let error as NSError {
            print("Hubo un error al guardar Nota", error.localizedDescription)
        }
    }
}
