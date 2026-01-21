<?php
declare(strict_types=1);

namespace App\Form\Type;

use App\Form\Field\GenderType;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\Extension\Core\Type\ButtonType;
use Symfony\Component\Form\Extension\Core\Type\DateType;
use Symfony\Component\Form\Extension\Core\Type\EnumType;
use Symfony\Component\Form\Extension\Core\Type\IntegerType;
use Symfony\Component\Form\Extension\Core\Type\SubmitType;
use Symfony\Component\Form\Extension\Core\Type\TextType;
use Symfony\Component\Form\FormBuilderInterface;

class UserFormType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options): void
    {
        $builder
            ->add('id', IntegerType::class, ['required' => false, 'attr' => ['class' => 'form-control'], 'label' => 'ID'])
            ->add('first_name', TextType::class, ['required' => false, 'attr' => ['class' => 'form-control'], 'label' => 'Imię'])
            ->add('last_name', TextType::class, ['required' => false, 'attr' => ['class' => 'form-control'], 'label' => 'Nazwisko'])
            ->add('gender', EnumType::class, ['class' => GenderType::class, 'required' => false, 'attr' => ['class' => 'form-control'], 'label' => 'Płeć'])
            ->add('birthdate', DateType::class, ['widget' => 'single_text', 'format' => 'yyyy-MM-dd', 'required' => false, 'attr' => ['class' => 'form-control'], 'label' => 'Data urodzenia'])
            ->add('submit', SubmitType::class, ['label' => 'Zapisz', 'attr' => ['class' => 'btn btn-primary', 'type' => 'submit']])
        ;
    }
}